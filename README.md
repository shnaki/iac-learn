# iac-learn

Terraform + LocalStack + Python で、Lambda / Fargate / Step Functions を学習するモノレポです。

## 構成

- `src/lambda`: Lambda の Python コード
- `src/fargate`: Fargate 用コンテナの Python コード
- `terraform/modules`: 再利用モジュール
- `terraform/environments/local`: LocalStack 用環境
- `terraform/environments/prod`: AWS 本番用環境

## 前提

- Docker / Docker Compose
- Dev Containers 対応環境（VS Code など）

## 開発環境の起動

```bash
docker compose up -d
```

Dev Container を開くと `postCreateCommand` で `uv` がインストールされ、dev 依存が同期されます。

利用可能コマンド:

- `terraform`
- `aws`
- `awslocal`（`scripts/awslocal` ラッパ）
- `tflocal`（`scripts/tflocal` ラッパ）

## Fargate イメージのビルド

LocalStack 検証用イメージを作成します。

```bash
docker build -t iac-learn/fargate:local -f src/fargate/Dockerfile .
```

## Terraform (LocalStack)

```bash
cd terraform/environments/local
terraform init
terraform validate
terraform apply -auto-approve
```

## Step Functions 実行確認 (LocalStack)

`terraform apply` 後に出力された State Machine ARN を使って実行します。

```bash
awslocal stepfunctions start-execution \
  --state-machine-arn <state-machine-arn> \
  --name demo-001 \
  --input '{"hello":"world"}'
```

実行履歴確認:

```bash
awslocal stepfunctions list-executions --state-machine-arn <state-machine-arn>
awslocal stepfunctions get-execution-history --execution-arn <execution-arn>
```

## 本番AWS向け

`terraform/environments/prod/terraform.tfvars.example` をコピーして値を設定し、通常の AWS Provider で実行します。

```bash
cd terraform/environments/prod
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
```
