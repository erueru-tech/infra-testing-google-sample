# scripts

このフォルダ内ではプロジェクトの構築に必要な以下のスクリプトを提供しています。

## setup_gcp_project.sh

このスクリプトでは検証に必要な Google Cloud プロジェクトのセットアップを行います。

なお Google Cloud プロジェクトは個人/会社ごとに設定やクォータ、作成方法、ポリシーなどが異なるため、汎用的な実装を行うことができません。

そのため、このスクリプトは基本的に erueru-tech の Google Cloud および開発環境に依存した実装となっており、**第三者の利用はまったく想定していません**。

また、必要最低限のテストしか行っていないため、予期せぬ問題が発生する可能性が十分に考えられます。

他にも google-cloud-sdk のバージョンアップにより、このスクリプトの処理が動かなくなるといった事象が何度か発生しています。

それでも、このスクリプトを使用する場合は、必ず**実行内容を精査した上で自分の組織の事情に合わせてコードを改変**するなどして利用してください。

このスクリプトを実行するための事前準備と手順について、開発者が把握する範囲で簡潔に説明すると以下のようになります。

### 事前準備

**1\.** Google Cloud の組織を作成。

**2\.** 組織に所属する Google Cloud プロジェクトを GCP コンソールから作成。

なおプロジェクト名は `$SERVICE + "-" + $ENV` のルールで作成する。

つまり、このサービスの sandbox 環境用プロジェクトを作成する場合は `infra-testing-google-sample-sbx-e` となる。

(ENV=sbx-e は開発チーム erueru-tech が使う sandbox 環境という意味)

ちなみに Google Cloud のプロジェクトの文字数上限は 30 文字までとなっており、`infra-testing-google-sample-sbx-e`はオーバーしているがあくまで例として捉える。

**3\.** 作成したプロジェクトの GCP コンソールにログインして、`請求先アカウントをリンク`で自分の組織に紐付け。

**4\.** 作成したプロジェクトの GCP コンソールにログインして、自分の IAM アカウントにプロジェクト削除保護設定ロールを追加。

ロール名は`リーエンの変更 | roles/resourcemanager.lienModifier`。

**5\.** ローカルのターミナルで`gcloud auth login`コマンドを実行してログイン。

**6\.** スクリプトの実行に必要なツールをインストール。

```bash
# Macの場合
$ brew install jq
$ brew install --cask google-cloud-sdk
$ gcloud components install alpha
$ gcloud components install beta
```

**7\.** scripts/\_config.sh に GCP プロジェクトセットアップ用の設定を記述。

```bash
$ cd /path/to/infra-testing-google-sample
$ vi scripts/_config.sh
# 以下の設定を記述
#!/bin/bash

# 組織のID
readonly ORG="123456789012"
# 組織のドメイン
readonly ORG_DOMAIN="foo-bar-12345.com"
# 以下のコマンドで確認できるBilling ID
# $ gcloud billing accounts list
readonly BILLING_ACCOUNT_ID="123456-7890AB-CDEF01"
# サービス名
readonly SERVICE="infra-testing-google-sample"
# 環境名(prod, stg, e.g.)
readonly ENV="sbx-e"
```

上記の他にも、新規セットアップから始めた場合に不足している手順がまだあると予想されます。

### Google Cloud プロジェクト セットアップ

実行準備が完了したら、以下のコマンドでプロジェクトのセットアップを行ないます。

冪等には作られているので、途中でエラー発生しても、問題箇所を修正して再実行すればいいようには実装されています。

```bash
$ cd /path/to/infra-testing-google-sample
$ scripts/setup_gcp_project.sh
```

セットアップ処理では以下のような処理を行なっています、

- \_config.sh で指定されたプロジェクト($SERVICE-$ENV)がまだ存在しなければ作成(プロジェクト作成権限が必要)
- ローカルの gcloud コマンドの適用先を\_config.sh で指定されたプロジェクトに切り替え
- プロジェクトの Billing 設定
- プロジェクトに必要な各種サービスの API を有効化
- プロジェクト削除保護(Lien)設定
- インフラ管理用のサービスアカウント作成
- Terraform の state 管理用バケット作成

なお現時点では確定していないものの、このスクリプトで作成されたリソースは意図的なドリフトを行うべきリソースである可能性が高いです。

意図的なドリフトとは destroy コマンド発行によって削除されてはいけないリソースを意図的に Terraform の管理から外すことを指します。

具体的なドリフトさせるべきリソースとしては、Terraform の state 管理バケットや、オーナーロールを持つアカウントおよびインフラ管理用のサービスアカウントなどが挙げられます。

## create_terraform_environment_template.sh

このリポジトリ内で管理する各環境用(prod, stg, test, sbx-x, e.g.)のテンプレート設定を自動的に作成するためのスクリプトです。

各環境の設定の作成先ディレクトリは[こちら](../terraform/environments/)。

以下のコマンドで新規に必要な環境用のディレクトリおよびファイルを作成します。

```bash
# sbx環境用のディレクトリおよびファイルを新規に構築する場合
# なお環境変数ではENV=sbx-eのように開発者を識別するためのサフィックス(-e)を付与していたが、ディレクトリ名はsbxになる
$ cd /path/to/infra-testing-google-sample
$ scripts/create_terraform_environment_template.sh sbx
```

## create_terraform_module_template.sh

このリポジトリ内で管理する Terraform モジュールのテンプレート設定を自動的に作成するためのスクリプトです。

モジュールの作成先ディレクトリは[こちら](../terraform/modules/)。

以下のコマンドで新規に作成するモジュールのディレクトリおよびファイルを作成します。

```bash
# appモジュールを作成する場合
$ cd /path/to/infra-testing-google-sample
$ scripts/create_terraform_module_template.sh app
```

## tflint.sh

Terraform の HCL ファイルに対する静的チェックを tfLint コマンドで実行するためのスクリプトです。

以下のコマンドで実行します。

```bash
$ cd /path/to/infra-testing-google-sample
$ scripts/tflint.sh
```
