import json
import os

import boto3


def _get_endpoint_url() -> str:
    """LocalStack エンドポイント URL を返す。"""
    host = os.environ.get("LOCALSTACK_HOST", "localhost:4566")
    return f"http://{host}"


def test_hello_lambda_returns_expected_response() -> None:
    """デプロイ済み Lambda を呼び出し、期待するレスポンスを確認する。"""
    client = boto3.client(
        "lambda",
        region_name="ap-northeast-1",
        endpoint_url=_get_endpoint_url(),
        aws_access_key_id="test",
        aws_secret_access_key="test",
    )
    payload = {"hello": "world"}

    response = client.invoke(
        FunctionName="iac-learn-hello-lambda",
        Payload=json.dumps(payload).encode(),
    )

    result = json.loads(response["Payload"].read())
    assert result["message"] == "Hello from Lambda!"
    assert result["input"] == payload
