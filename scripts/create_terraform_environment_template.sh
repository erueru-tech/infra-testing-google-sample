#!/usr/bin/env bash

set -eu

readonly SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
readonly ROOT_DIR=$(cd $SCRIPTS_DIR && cd .. && pwd)
readonly TERRAFORM_DIR=$ROOT_DIR/terraform
readonly ENV=$1
readonly ENV_DIR=$TERRAFORM_DIR/environments/$ENV
readonly TIERS=(
  "tier1"
  "tier2"
)
readonly NEW_TF_FILES=(
  "backend.tf"
  "main.tf"
  "variables.tf"
  "outputs.tf"
  "auto.tfvars"
)
readonly LINK_TF_FILES=(
  "environment-globals.tf"
  "globals.tf"
  "tier1-main.tf"
  "tier1-variables.tf"
  "tier1-outputs.tf"
  "tier2-main.tf"
  "tier2-variables.tf"
  "tier2-outputs.tf"
)

if [[ "$ENV" != "prod" && "$ENV" != "stg" && "$ENV" != "test" && "$ENV" != "sbx" ]]; then
  echo "The value of \$ENV must be 'prod', 'stg', 'test' or 'sbx', but it is '$ENV'."
  exit 1
fi

if [[ -d $ENV_DIR ]]; then
  echo "$ENV directory already exists"
  exit 1
fi

for TIER in "${TIERS[@]}"; do
  TIER_DIR=$ENV_DIR/$TIER
  mkdir -p $TIER_DIR/tests
  echo "create $TIER directory"

  for FILE in "${NEW_TF_FILES[@]}"; do
    # variables.tfにはenv変数を最初から宣言しておく
    if [[ $FILE == variables.tf ]]; then
      if [[ $ENV == "sbx" ]]; then
        condition="condition     =  startswith(var.env, \"sbx-\")"
        error_message="error_message = \"The value of var.env must start with 'sbx-', but it is '\${var.env}'.\""
      else
        condition="condition     = var.env == \"$ENV\""
        error_message="error_message = \"The var.env value must be '$ENV', but it is '\${var.env}'.\""
      fi
      cat <<EOF > $TIER_DIR/$FILE
variable "env" {
  type    = string
  default = null
  validation {
    $condition
    $error_message
  }
}
EOF
    # backend.tfに必要な宣言を事前にしておく
    elif [[ $FILE == backend.tf ]]; then
      cat <<EOF > $TIER_DIR/$FILE
terraform {
  backend "gcs" {
    # オープンソースであるため、自分のプロジェクトの名前がバレないように適当な名前を設定している
    # なお、terraform init実行の際は、以下のように動的にstate管理用GCSバケット名を指定すればよい
    # $ terraform init -backend-config="bucket=your-terraform-bucket-name"
    # ちなみにprod環境とsandbox環境以外はGCSバケット名を直書きして、Gitで管理しても問題ないと考えている
    # prod環境についてはローカルから誤って、destroyコマンドを発行しないよう意図的にバケット名をそのままや適当な名前にして、
    # 本番リリースCI/CD時に-backend-configオプションでstate管理バケットを指定するような運用を想定している
    # sandbox環境は直書きしても問題ないが、自分用の環境のバケット設定を維持するためにこのフォルダ内の.gitignoreに
    # backend.tf(このファイル)を指定するなどしてGit管理されないようにする

    bucket  = "your-terraform-bucket-name"
    prefix  = "terraform/$TIER-state"
  }
}
EOF
    elif [[ $FILE == auto.tfvars ]]; then
      touch $TIER_DIR/$ENV-$TIER.$FILE
    else
      touch $TIER_DIR/$FILE
    fi
    echo "create $FILE"
  done

  for FILE in "${LINK_TF_FILES[@]}"; do
    if [[ $FILE != tier* || $FILE == $TIER* ]]; then
      ln -s ../../../$FILE $TIER_DIR/$FILE
      echo "link ../../../$FILE to $FILE"
    fi
  done
done

# tier2がtier1のouputを参照できるようにする設定ファイルを追加
cat <<EOF > $ENV_DIR/tier2/data.tf
data "terraform_remote_state" "tier1" {
  backend = "gcs"
  config = {
    bucket  = "\${local.project_id}-terraform"
    prefix  = "terraform/tier1-state"
  }
}
EOF
echo "create tier2/data.tf"

# sandbox環境ではsbx-tier(1|2).auto.tfvarsファイルの値が、個人環境に依存する値となるので.gitignoreに設定する
if [[ "$ENV" == "sbx" ]]; then
  echo "sbx-tier*.auto.tfvars" >> $ENV_DIR/.gitignore
  echo "create .gitignore"
fi

# testおよびsandbox環境ではterraformコマンド実行のヘルパースクリプトを追加
if [[ "$ENV" == "test" || "$ENV" == "sbx" ]]; then
  ln -s ../../scripts/apply.sh $ENV_DIR/tier1/apply.sh
  echo "link ../../scripts/apply.sh to tier1/apply.sh"
  ln -s ../../scripts/apply.sh $ENV_DIR/tier2/apply.sh
  echo "link ../../scripts/apply.sh to tier2/apply.sh"
  ln -s ../../scripts/destroy.sh $ENV_DIR/tier2/destroy.sh
  echo "link ../../scripts/destroy.sh to tier2/destroy.sh"
fi
