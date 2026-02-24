# 開発ガイドライン

このドキュメントには、このコードベースで作業するうえで重要な情報が含まれています。以下のガイドラインを厳密に守ってください。

## コア開発ルール

1. パッケージ管理
   - `uv` のみを使用し、`pip` は絶対に使用しない
   - インストール: `uv add <package>`
   - ツール実行: `uv run <tool>`
   - アップグレード: `uv lock --upgrade-package <package>`
   - 禁止: `uv pip install`、`@latest` 構文

2. コード品質
   - すべてのコードに型ヒントが必須
   - 公開 API には docstring（ドキュメンテーション文字列）を必ず記述する
   - 関数は小さく、責務を絞る
   - 既存パターンに正確に従う
   - 行長: 最大 88 文字（`pyproject.toml` の Ruff 設定に従う）
   - 禁止: 関数内 import。必ずファイル先頭に配置すること。

3. テスト要件
   - フレームワーク: `uv run --frozen pytest`
   - 非同期テスト: `asyncio` ではなく `anyio` を使用する
   - `Test` 接頭辞のクラスは使わず、関数を使う
   - カバレッジ: エッジケースとエラーをテストする
   - 新機能にはテストが必須
   - バグ修正にはリグレッションテスト（回帰テスト）が必須
   - 重要: 既存の `tests/lambda/test_handler.py` と `tests/fargate/test_app.py` のテストスタイルに従ってください。
   - 重要: 最小限を心がけ、I/O 境界（Lambda ハンドラ・アプリエントリポイント）を優先してテストしてください。
   - 重要: プッシュ前に、変更したファイルのブランチカバレッジ（branch coverage）が 100% であることを `uv run --frozen pytest -x` で確認してください（`pyproject.toml` で `fail_under = 100` と `branch = true` が設定されています）。未カバーの分岐がある場合は、プッシュ前に必ずテストを追加してください。
   - 非同期処理の待機に、固定時間の `anyio.sleep()` は避けてください。代わりに:
     - `anyio.Event` を使用する: コールバック/ハンドラで `set` し、テストでは `await event.wait()` する
     - ストリームメッセージでは、`sleep()` + `receive_nowait()` ではなく `await stream.receive()` を使う
     - 例外: 時間依存の機能（例: タイムアウト）をテストする場合は `sleep()` の使用が適切
   - 無期限待機（`event.wait()`、`stream.receive()`）はハング防止のため `anyio.fail_after(5)` で囲む

テストファイルはソースツリーを反映します（例: `src/lambda/handler.py` → `tests/lambda/test_handler.py`、`src/fargate/app.py` → `tests/fargate/test_app.py`）。
対象モジュールの既存テストファイルにテストを追加してください。

- ユーザー報告に基づくバグ修正や機能追加のコミットには、以下を追加:

  ```bash
  git commit --trailer "Reported-by:<name>"
  ```

  `<name>` にはユーザー名を入れてください。

- GitHub Issue 関連のコミットには、以下を追加:

  ```bash
  git commit --trailer "Github-Issue:#<number>"
  ```

- `co-authored-by` や類似表現は絶対に記載しないこと。特に、コミットメッセージや PR の作成に使ったツールには言及しないでください。

## コミットメッセージ規約

- コミットメッセージは Angular/Conventional Commits 形式で統一すること。
- 基本形式は `<type>(<scope>)?: <subject>` を使用すること。
- `scope` は任意。不要な場合は省略してよい。
- `subject` は簡潔な日本語で記述し、原則として文末の句点は付けないこと。
- 使用可能な `type`:
  - `feat`: 新機能
  - `fix`: バグ修正
  - `docs`: ドキュメント変更
  - `refactor`: 振る舞いを変えない内部改善
  - `test`: テスト追加・修正
  - `chore`: 雑務・メンテナンス
  - `ci`: CI 設定変更
  - `build`: ビルド/依存関係変更
  - `perf`: 性能改善
  - `revert`: 変更取り消し
- 破壊的変更がある場合は `type(scope)!: ...` 形式、またはコミット本文に `BREAKING CHANGE:` を記載すること。
- 既存のコミットトレーラー規約（`Reported-by`、`Github-Issue`）は維持し、必要に応じて併用すること。

## プルリクエスト

- 何を変更したかを詳しく記述してください。解決しようとしている問題の高レベルな説明と、その解決方法に焦点を当ててください。明確さが増す場合を除き、コードの詳細には踏み込まないでください。

- `co-authored-by` や類似表現は絶対に記載しないこと。特に、コミットメッセージや PR の作成に使ったツールには言及しないでください。

## 破壊的変更

破壊的変更を行う場合は、`docs/migration.md` に記録してください。以下を含めます:

- 何が変わったか
- なぜ変えたか
- 既存コードをどう移行するか

移行ガイド内の関連セクションを探し、新しい独立セクションを増やすのではなく、関連する変更をまとめて記載してください。

## Python ツール

## コードフォーマット

1. Ruff
   - フォーマット: `uv run --frozen ruff format .`
   - チェック: `uv run --frozen ruff check .`
   - 修正: `uv run --frozen ruff check . --fix`
   - 重要項目:
     - 行長（88 文字）
     - import の並び替え（I001）
     - 未使用 import
   - 改行ルール:
     - 文字列: かっこで囲む
     - 関数呼び出し: 適切なインデントで複数行化
     - import: 可能な限り 1 行で記述

2. 型チェック
   - ツール: `uv run --frozen pyright`
   - 要件:
     - 文字列に対する型絞り込み
     - チェックが通るならバージョン警告は無視可

3. Pre-commit
   - 設定: `.pre-commit-config.yaml`
   - 実行タイミング: git commit 時
   - ツール: Prettier（YAML/JSON）、Ruff（Python）
   - Ruff 更新時:
     - PyPI のバージョンを確認
     - 設定の `rev` を更新
     - 先に設定ファイルをコミット

4. Terraform
   - `.tf` ファイルを変更したら必ず `terraform fmt -recursive terraform/` を実行する
   - 確認のみ: `terraform fmt -check -recursive terraform/`
   - pre-commit には Terraform フォーマッタが含まれないため、手動実行が必要

## エラー解決

1. CI 失敗
   - 修正順序:
     1. フォーマット
     2. 型エラー
     3. Lint（静的解析）
   - 型エラー対応:
     - 該当行の前後文脈を十分に確認
     - Optional 型を確認
     - 型絞り込みを追加
     - 関数シグネチャを検証

2. よくある問題
   - 行長:
     - 文字列をかっこで分割
     - 関数呼び出しを複数行化
     - import を分割
   - 型:
     - None チェックを追加
     - 文字列型を絞り込む
     - 既存パターンに合わせる

3. ベストプラクティス
   - コミット前に `git status` を確認
   - 型チェック前にフォーマッタを実行
   - 変更は最小限に保つ
   - 既存パターンに従う
   - 公開 API をドキュメント化
   - テストを十分に行う

## 例外処理

- **例外を捕捉する場合は、`logger.error()` ではなく必ず `logger.exception()` を使用する**
  - メッセージ内に例外を含めない: `logger.exception("Failed")` を使い、`logger.exception(f"Failed: {e}")` は使わない
- **可能な限り具体的な例外を捕捉する**:
  - ファイル操作: `except (OSError, PermissionError):`
  - JSON: `except json.JSONDecodeError:`
  - ネットワーク: `except (ConnectionError, TimeoutError):`
- **禁止** `except Exception:` - トップレベルハンドラを除く
