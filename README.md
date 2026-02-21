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

LocalStack は Dev Container 起動時に自動で起動されます。
手動で起動する場合は以下を実行してください。

```bash
docker compose up -d localstack
```

Dev Container を開くと `postCreateCommand` で `uv` がインストールされ、dev 依存が同期されます。
Dev Container を終了しても LocalStack コンテナは動作し続けます。

停止する場合:

```bash
docker compose stop localstack
docker compose down
```

利用可能コマンド:

- `terraform`
- `aws`
- `awslocal`（`scripts/awslocal` ラッパ）
- `tflocal`（`scripts/tflocal` ラッパ）

## 品質チェック

```bash
uv run --frozen pytest
uv run --frozen ruff check .
uv run --frozen pyright
```

pre-commit でも同等のチェックを実行できます。

```bash
uv run --frozen pre-commit run --all-files
```

## コミットメッセージテンプレート

Conventional Commits 形式のテンプレートを `.gitmessage` で管理しています。

セットアップ:

```bash
git config commit.template .gitmessage
```

確認:

```bash
git config --get commit.template
git commit
```

運用メモ:

- 件名は `<type>(<scope>)?: <subject>` 形式
- `subject` は簡潔な日本語で、原則として文末の句点なし
- GitHub Issue は件名末尾 `#123` の併記は可、正式には `Github-Issue:#123` trailer を推奨
- ユーザー報告由来の変更は `Reported-by:<name>` trailer を追加
- `co-authored-by` やコミット作成ツールへの言及は記載しない

## Fargate イメージのビルド

LocalStack 検証用イメージを作成します。

```bash
docker build -t iac-learn/fargate:local -f src/fargate/Dockerfile .
```

## Terraform (LocalStack)

Terraform のバージョンとプロバイダー要件は `versions.tf` に分離しています。

```bash
cd terraform/environments/local
terraform init
terraform validate
terraform apply -auto-approve
```

## CloudFormation

Terraform とほぼ同等の構成を `cloudformation/` 配下に用意しています。
構成は root stack + nested stacks（`network`/`lambda`/`ecs-fargate`/`stepfunctions`）です。

### 1. 事前準備

- Lambda ZIP を作成して S3 に配置する
- Fargate イメージを事前にビルド・Push する
- `cloudformation/` 配下テンプレートを S3 に配置する

例:

```bash
aws s3 cp cloudformation/root.yaml s3://<template-bucket>/cloudformation/root.yaml
aws s3 cp cloudformation/stacks/network.yaml s3://<template-bucket>/cloudformation/stacks/network.yaml
aws s3 cp cloudformation/stacks/lambda.yaml s3://<template-bucket>/cloudformation/stacks/lambda.yaml
aws s3 cp cloudformation/stacks/ecs-fargate.yaml s3://<template-bucket>/cloudformation/stacks/ecs-fargate.yaml
aws s3 cp cloudformation/stacks/stepfunctions.yaml s3://<template-bucket>/cloudformation/stacks/stepfunctions.yaml
```

### 2. パラメータファイル作成

- 本番向け: `cloudformation/params/prod.example.json`
- ローカル検証向け: `cloudformation/params/local.example.json`

必要な値（`TemplateBaseUrl`、Lambda ZIP の S3 情報、`ContainerImageUri`）を実値に変更してください。

### 3. 静的検証

```bash
aws cloudformation validate-template --template-body file://cloudformation/root.yaml
aws cloudformation validate-template --template-body file://cloudformation/stacks/network.yaml
aws cloudformation validate-template --template-body file://cloudformation/stacks/lambda.yaml
aws cloudformation validate-template --template-body file://cloudformation/stacks/ecs-fargate.yaml
aws cloudformation validate-template --template-body file://cloudformation/stacks/stepfunctions.yaml
```

### 4. デプロイ例（AWS）

```bash
aws cloudformation create-stack \
  --stack-name iac-learn \
  --template-body file://cloudformation/root.yaml \
  --parameters file://cloudformation/params/prod.example.json \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND
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
