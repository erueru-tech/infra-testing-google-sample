# infra-testing-google-sample

自動テスト可能なインフラストラクチャの実装および運用を行うための Terraform プロジェクトのサンプルで、クラウドサービスは[Google Cloud](https://cloud.google.com/free/?utm_source=google&utm_medium=cpc&utm_campaign=japac-JP-all-ja-dr-BKWS-all-core-trial-EXA-dr-1605216&utm_content=text-ad-none-none-DEV_c-CRE_602341359562-ADGP_Hybrid+%7C+BKWS+-+EXA+%7C+Txt+~+GCP_General_core+brand_main-KWID_43700071566406795-kwd-6458750523&userloc_1009501-network_g&utm_term=KW_google+cloud&gad_source=1&gclid=CjwKCAiAloavBhBOEiwAbtAJO95rgNb1GPBj0MeixreE8ai1B6rNLDGW4UV8UtVtN5F1kLGx_KoYvRoCYfYQAvD_BwE&gclsrc=aw.ds&hl=ja)を使用しています。

なお現時点では、プロトタイプ版未満の完成度であるため、コード利用の際は処理内容などを精査した上で利用してください。

## 基本情報

### 変数

このリポジトリ内で使用される環境変数は、それぞれ以下のような意味となっています。

| 変数名        | 説明                                                                                                                                                                                                                                                                                      |
| ------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SERVICE       | インフラ構築対象のサービス名あるいはプロダクト名。<br/>このプロジェクトでは`infra-testing-google-sample`(実際には存在しないサービス)としている。                                                                                                                                          |
| ENV           | サービスの開発/運用が行われる環境の名前。<br/>詳細は下記`環境`参照。                                                                                                                                                                                                                      |
| PROJECT(\_ID) | 各環境に紐づく Google Cloud プロジェクトの名前。<br/>このインフラプロジェクトでは`$SERVICE-$ENV`のルールで命名していて、prod 環境の場合は`infra-testing-google-sample-prod`となる 。<br/>なお Google Cloud のプロジェクト名は 30 文字であるためこのプロジェクト名は実際には使用できない。 |

### 環境

infra-testing-google-sample サービスで使用する環境は、`prod`、`stg`、`test`、`sbx-e`の 4 種類を想定しています。

各環境の詳細は以下のようになります。

| 環境  | CIDR        | 説明                                                                                                                                                                                  |
| ----- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| prod  | 10.1.0.0/16 | infra-testing-google-sample サービスの本番環境。<br/>                                                                                                                                 |
| stg   | 10.2.0.0/16 | infra-testing-google-sample サービスの staging 環境。<br/>                                                                                                                            |
| test  | 10.3.0.0/16 | infra-testing-google-sample サービスの CI 専用テスト実行環境。<br/>                                                                                                                   |
| sbx-e | 10.4.0.0/16 | infra-testing-google-sample サービスの個人開発用(sandbox)環境。<br/>所有者を識別するためのサフィックスを sbx の後に付与する。<br/>例として開発者が erueru-tech の場合、sbx-e となる。 |

## 実行手順

**現時点でこのリポジトリのコードは、あくまでコードサンプルの公開のみを目的としていて、実際に動作させることは想定していません。**

(将来的にプロトタイプ版が完成して、それが実際のサービスでの運用に耐えられると判断された際には、テンプレートリポジトリ化する予定)

それでも個人環境で動作検証を行いたい場合は、[scripts/README.md](./scripts/README.md)の手順を参考に Google Cloud プロジェクトのセットアップを完了させてください。

セットアップが完了したら、[environments](./terraform/environments/) ディレクトリや [modules](./terraform/modules/) ディレクトリ配下で terraform init、plan、apply、destroy コマンドを適切な変数を与えて実行することで、インフラストラクチャの構築やテストを行うことができます。

**(※以下で説明されているコマンドを実行すると課金が発生する点にご注意ください)**

sandbox 環境では以下のようなコマンドでインフラストラクチャの構築や動作確認を行います。

なおコマンド実行の前提として、以下のような変数がターミナルに設定されている必要があります。

```bash
SERVICE=infra-testing-google-sample
ENV=sbx-e
PROJECT=$SERVICE-$ENV
```

まず初めに [environments](./terraform/environments/) ディレクトリ内にある sandbox 環境用の [tier1](./terraform/environments/sbx/tier1/) ディレクトリ内に定義されているリソースを作成します。

tier1 には Google Cloud のサービス API の有効化の設定や、VPC などのネットワーク設定といった基本的に destroy を行わないようにしたいモジュールやリソースを定義しています。

リソースの作成は以下のコマンドで行います。

```bash
$ cd /path/to/infra-testing-google-sample/terraform/environments/sbx/tier1

# Terraformのstate管理バケットを動的に指定
$ terraform init -backend-config="bucket=$PROJECT-terraform"

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
terraform plan

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
terraform apply -auto-approve
```

以上で API の有効化と VPC などのネットワークリソースの作成が完了します。

次に [tier2](./terraform/environments/sbx/tier2/) ディレクトリ内に定義されているリソースを作成します。

tier2 には test 環境や sandbox 環境でコストの面から常時稼働させたくない、かつ destroy を行なっても問題のないモジュールやリソースを定義しています。

リソースの作成は以下のコマンドで行います。

```bash
$ cd ../tier2

$ terraform init -backend-config="bucket=$PROJECT-terraform"

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
terraform plan

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
terraform apply -auto-approve

# このモジュールでterraform destroyを実行すると以下のエラーが発生してgoogle_service_networking_connectionリソースを削除できない
# https://github.com/hashicorp/terraform-provider-google/issues/16275
# ワークアラウンドとしてgoogle-betaプロバイダのバージョンを4.x系に戻すか、必ず以下のコマンドを実行してからdestroyを実行する必要がある
$ gcloud compute networks peerings delete servicenetworking-googleapis-com --network sample-vpc --project $PROJECT

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
terraform destroy
```

以上で sandbox 環境の構築は完了となります。

次にモジュール単位で Terraform の設定ファイルの挙動を確認したい場合は、[modules](./terraform/modules/) ディレクトリ配下の各モジュールのディレクトリ内で terraform コマンドを実行します。

まず network モジュールの動作確認は以下でコマンド行います。

```bash
$ cd /path/to/infra-testing-google-sample/terraform/modules/network

# モジュールのリソースをstate管理すべきかは現在検討中
# 現時点ではローカルにstateファイルを作成する想定
$ terraform init

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
TF_VAR_subnet_ip=10.4.101.0/24 \
terraform plan

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
TF_VAR_subnet_ip=10.4.101.0/24 \
terraform apply -auto-approve

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
TF_VAR_subnet_ip=10.4.101.0/24 \
terraform destroy
```

次に db モジュールの動作確認は以下でコマンド行います。

```bash
$ cd ../db

$ terraform init

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
TF_VAR_vpc_id=projects/$PROJECT/global/networks/sample-vpc \
TF_VAR_vpc_name=sample-vpc \
TF_VAR_cloudsql_network_address=10.4.102.0 \
terraform plan

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
TF_VAR_vpc_id=projects/$PROJECT/global/networks/sample-vpc \
TF_VAR_vpc_name=sample-vpc \
TF_VAR_cloudsql_network_address=10.4.102.0 \
terraform apply -auto-approve

gcloud compute networks peerings delete servicenetworking-googleapis-com --network sample-vpc --project $PROJECT

$ TF_VAR_service=$SERVICE \
TF_VAR_env=$ENV \
TF_VAR_vpc_id=projects/$PROJECT/global/networks/sample-vpc \
TF_VAR_vpc_name=sample-vpc \
TF_VAR_cloudsql_network_address=10.4.102.0 \
terraform destroy
```

以上が動作確認の基本的な方法となります。

## 開発

このプロジェクトの開発では以下のツールを利用しています。

各ツールのインストールの手順は公式ドキュメントを参照してください。

- [tfenv](https://github.com/tfutils/tfenv?tab=readme-ov-file#installation)
- [TFLint](https://github.com/terraform-linters/tflint?tab=readme-ov-file#installation)
- [pre-commit](https://pre-commit.com/#install)

## バージョン

このプロジェクトでは[セマンティックバージョン](https://semver.org/lang/ja/)を採用しています。

基本的には機能を追加するたびにマイナーバージョンを更新して、のちにバグや訂正項目が見つかった場合にはパッチバージョンを更新します。

なお、メジャーバージョンはこのプロジェクトのコンセプトが現実のサービスに対して適用可能であることを確認できた場合に更新されます。

## 貢献

(まずあり得ないとは思うものの、)現時点では設計方針が大幅に変更され続ける可能性なども踏まえて、申し訳ありませんがコントリビューションは現在受け付けておりません。

それとは別に、もし何か重大なバグや設計上の問題などを発見した方は Issue などを作成していただければ幸いです。

(返答に時間がかかる点についてはご容赦ください)

## ライセンス

このリポジトリのライセンスは MIT であるため、改変、再配布、商用利用等は基本的に自由となります。

## 免責事項

このリポジトリ内のあらゆるソースコードの利用によって不利益を被った場合におきましても、その不利益に関して一切の責任を負いかねます。

## 情報

設計に関する詳細は[ブログ](https://zenn.dev/erueru_tech)などで公開していますので、興味のある方はそちらを確認してください。
