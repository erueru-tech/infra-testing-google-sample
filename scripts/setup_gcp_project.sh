#!/bin/bash

set -eu

readonly SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
readonly CONFIG_FILE_PATH="$SCRIPTS_DIR/_config.sh"

[ -e $CONFIG_FILE_PATH ] && source $CONFIG_FILE_PATH
source "$SCRIPTS_DIR/_utils.sh"

# variables
readonly PROJECT=$SERVICE-$ENV
readonly REQUIRED_CONFIG_VARS=(
  "ORG"
  "ORG_DOMAIN"
  "BILLING_ACCOUNT_ID"
  "SERVICE"
  "ENV"
)
readonly NECESSARY_GCLOUD_COMPONENTS=(
  "alpha"
  "beta"
)
readonly SERVICES=(
  "cloudbilling.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "iam.googleapis.com"
  "compute.googleapis.com"
  "cloudasset.googleapis.com"
)
readonly ADMIN_SA="infra-admin"
readonly ADMIN_SA_EMAIL="$ADMIN_SA@$PROJECT.iam.gserviceaccount.com"
readonly BUCKET="gs://$PROJECT-terraform"

# functions
function run() {
  if $DRY_RUN; then
    echo "$1"
  else
    $2
  fi
}

# parse options
DRY_RUN=false
while getopts d option; do
  case "$option" in
    d) DRY_RUN=true;;
    \?) exit 1;;
  esac
done
shift $((--OPTIND))

# validation checks

# 必須の変数が_config.shに定義されていることを確認
for VAR in "${REQUIRED_CONFIG_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "[ERROR] '$VAR' is a required variable that must be set in _config.sh"
    exit 1
  fi
done

# 組織のアカウントでログインしていることを確認
readonly ACCOUNT=`gcloud config get-value account`
if [[ $ACCOUNT != *@$ORG_DOMAIN ]]; then
  echo "[ERROR] Your GCP account ($ACCOUNT) has to belong to '@$ORG_DOMAIN'"
  exit 1
fi

# jqコマンドがインストールされていることを確認
if ! which jq >/dev/null 2>&1; then
  echo "[ERROR] The 'jq' command does not exist. Please refer to the following page for installation instructions."
  echo "https://jqlang.github.io/jq/download/"
  exit 1
fi

# 実行者のアカウントがオーナーであることを確認
# ref. https://cloud.google.com/sdk/gcloud/reference/projects/get-iam-policy
readonly ACCOUNT_ROLES=`gcloud projects get-iam-policy --format=json $PROJECT |\
  jq -r ".bindings[] | select(.members[] == \"user:$ACCOUNT\") | .role"`
if ! printf '%s\n' "${ACCOUNT_ROLES[@]}" | grep -qx "roles/owner"; then
  echo  "[ERROR] Your GCP account ($ACCOUNT) has to be granted 'roles/owner'"
  exit 1
fi

# gcloudのalphaとbetaコンポーネントがインストールされていることを確認
readonly INSTALLED_COMPONENTS=`gcloud components list --only-local-state`
for COMPONENT in "${NECESSARY_GCLOUD_COMPONENTS[@]}"; do
  if ! printf '%s\n' "${INSTALLED_COMPONENTS[@]}" | grep " $COMPONENT " > /dev/null 2>&1; then
    echo "[ERROR] gcloud component '$COMPONENT' is not installed. Please download and install it by executing the below command"
    echo "$ gcloud components install $COMPONENT"
    exit 1
  fi
done

# gsutilコマンドがインストールされていることを確認
if ! which gsutil >/dev/null 2>&1; then
  echo "[ERROR] The 'gsutil' command does not exist. Please refer to the following page for installation instructions."
  echo "https://cloud.google.com/storage/docs/gsutil_install"
  exit 1
fi

# create a project

# GCPプロジェクトの作成
# ref. https://cloud.google.com/sdk/gcloud/reference/projects/create
cmd="gcloud projects create $PROJECT --name=$PROJECT --organization=$ORG --set-as-default"
function to_make_project() {
  # gcloud projects create if not exists
  # ref. https://cloud.google.com/sdk/gcloud/reference/projects/describe
  if ! gcloud projects describe $PROJECT > /dev/null 2>&1; then
    echo "create a new gcp project ($PROJECT) ..."
    eval $cmd
  else
    echo "The project ($PROJECT) has already been created"
  fi
}
run "$cmd" to_make_project

# ローカルのGCPプロジェクトを作成したプロジェクトに切り替える
gcloud config set project $PROJECT

# GCPプロジェクトをBillingと紐付ける
# ref. https://cloud.google.com/sdk/gcloud/reference/beta/billing/projects/link
# --billing-accountの値は以下のコマンドで確認
# $ gcloud billing accounts list
cmd="gcloud beta billing projects link $PROJECT --billing-account=$BILLING_ACCOUNT_ID"
function to_enable_billing() {
  # ref. https://cloud.google.com/sdk/gcloud/reference/beta/billing/projects/describe
  if ! gcloud beta billing projects describe $PROJECT --format=json | jq .billingEnabled > /dev/null 2>&1; then
    echo "enable billing on the project ($PROJECT)"
    eval $cmd
  fi
}
run "$cmd" to_enable_billing

# APIの有効化
# ref. https://cloud.google.com/endpoints/docs/openapi/enable-api?hl=ja#gcloud
for SRV in "${SERVICES[@]}"; do
  cmd="gcloud services enable --project=$PROJECT $SRV"
  function to_enable_api_service() {
    # ref. https://cloud.google.com/sdk/gcloud/reference/services/list
    enabled_services=`gcloud services list --enabled --project=$PROJECT`
    if ! echo "${enabled_services[@]}" | grep -E "^$SRV " > /dev/null 2>&1; then
      echo "enable service $SRV"
      eval $cmd
    fi
  }
  run "$cmd" to_enable_api_service
done

# プロジェクト削除保護のためにLien設定(sandbox環境は除く)
# ref. https://cloud.google.com/sdk/gcloud/reference/alpha/resource-manager/liens/create
if [[ $ENV != "sbx"* ]]; then
  readonly reason="The $ENV environment does not allow project deletion."
  cmd=`cat <<EOF
gcloud alpha resource-manager liens create --project=$PROJECT \
--restrictions=resourcemanager.projects.delete \
--reason="$reason"
EOF`
  function to_deny_prject_deletion() {
    # ref. https://cloud.google.com/sdk/gcloud/reference/alpha/resource-manager/liens/list
    liens=`gcloud alpha resource-manager liens list --project=$PROJECT`
    if ! echo "${liens[@]}" | grep "$reason" > /dev/null 2>&1; then
      echo "enable the project deletion"
      eval "$cmd"
    fi
  }
  run "$cmd" to_deny_prject_deletion
fi

# インフラ管理用のサービスアカウント作成
# ref. https://cloud.google.com/sdk/gcloud/reference/iam/service-accounts/create
# ref. https://cloud.google.com/sdk/gcloud/reference/projects/add-iam-policy-binding
# gcloud iam service-accounts createコマンドは--projectの指定が効かず、gcloud confi get projectのプロジェクトにSAを作成しようとする点に注意
cmd=`cat <<EOF
gcloud iam service-accounts create $ADMIN_SA --display-name="$ADMIN_SA"
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$ADMIN_SA_EMAIL" --role="roles/owner"
EOF`
function to_create_service_account() {
  if ! gcloud iam service-accounts describe $ADMIN_SA_EMAIL --project=$PROJECT > /dev/null 2>&1; then
    echo "create a admin service account"
    eval "${cmd}"
  fi
}
run "$cmd" to_create_service_account

# Terraformのstate管理用バケット作成
# ref. https://cloud.google.com/storage/docs/gsutil/commands/mb
cmd=`cat <<EOF
gsutil mb -p $PROJECT -c multi_regional -l Asia $BUCKET
gsutil versioning set on $BUCKET
EOF`
function to_make_bucket() {
  if ! gsutil ls -b $BUCKET > /dev/null 2>&1; then
    echo "make a bucket for Terraform and enable versioning"
    eval "${cmd}"
  fi
}
run "$cmd" to_make_bucket
