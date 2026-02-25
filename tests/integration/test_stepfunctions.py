import os
import time
from typing import Any

import boto3

_TERMINAL_STATES = {"SUCCEEDED", "FAILED", "TIMED_OUT", "ABORTED"}
_POLL_INTERVAL = 2
_MAX_WAIT = 30


def _get_endpoint_url() -> str:
    """LocalStack エンドポイント URL を返す。"""
    host = os.environ.get("LOCALSTACK_HOST", "localhost:4566")
    return f"http://{host}"


def test_stepfunctions_execution_succeeds(
    terraform_outputs: dict[str, Any],
) -> None:
    """State Machine を実行し、SUCCEEDED で完了することを確認する。"""
    client = boto3.client(
        "stepfunctions",
        region_name="ap-northeast-1",
        endpoint_url=_get_endpoint_url(),
        aws_access_key_id="test",
        aws_secret_access_key="test",
    )
    state_machine_arn = terraform_outputs["stepfunctions_state_machine_arn"]

    start_response = client.start_execution(stateMachineArn=state_machine_arn)
    execution_arn = start_response["executionArn"]

    elapsed = 0
    status = ""
    while elapsed < _MAX_WAIT:
        describe_response = client.describe_execution(executionArn=execution_arn)
        status = describe_response["status"]
        if status in _TERMINAL_STATES:
            break
        time.sleep(_POLL_INTERVAL)
        elapsed += _POLL_INTERVAL

    assert status == "SUCCEEDED", (
        f"State Machine が SUCCEEDED になりませんでした: {status}"
    )
