terraform {
  backend "gcs" {
    # オープンソースであるため、自分のプロジェクトの名前がバレないように適当な名前を設定している
    # なお、terraform init実行の際は、以下のように動的にstate管理用GCSバケット名を指定すればよい
    # $ terraform init -backend-config="bucket=your-terraform-bucket-name"
    # ちなみにprod環境とsandbox環境以外はGCSバケット名を直書きして、Gitで管理しても問題ないと考えている
    # prod環境についてはローカルから誤って、destroyコマンドを発行しないよう意図的にバケット名をそのままや適当な名前にして、
    # 本番リリースCI/CD時に-backend-configオプションでstate管理バケットを指定するような運用を想定している
    # sandbox環境は直書きしても問題ないが、自分用の環境のバケット設定を維持するためにこのフォルダ内の.gitignoreに
    # terraform.tf(このファイル)を指定するなどしてGit管理されないようにする

    bucket = "your-terraform-bucket-name"
    prefix = "terraform/tier1-state"
  }
}
