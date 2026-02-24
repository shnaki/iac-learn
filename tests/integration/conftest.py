import os
import socket
from pathlib import Path
from typing import Any

import pytest
import tftest  # type: ignore[import-untyped]

_TERRAFORM_DIR = str(
    Path(__file__).parent.parent.parent / "terraform" / "environments" / "local"
)


def _is_localstack_available() -> bool:
    """LocalStack が起動しているか確認する。"""
    localstack_host = os.environ.get("LOCALSTACK_HOST", "localhost:4566")
    host, _, port_str = localstack_host.partition(":")
    port = int(port_str) if port_str else 4566
    try:
        with socket.create_connection((host, port), timeout=1):
            return True
    except OSError:
        return False


def pytest_collection_modifyitems(items: list[pytest.Item]) -> None:
    """LocalStack が利用不可な場合は統合テストをスキップする。"""
    if _is_localstack_available():
        return
    skip_marker = pytest.mark.skip(reason="LocalStack が起動していません")
    for item in items:
        item.add_marker(skip_marker)


@pytest.fixture(scope="session")
def terraform_outputs() -> dict[str, Any]:
    """Terraform の output を返す。CI では apply も実行する。"""
    tf = tftest.TerraformTest(_TERRAFORM_DIR)
    if os.environ.get("CI"):
        tf.setup()
        tf.apply()
    return tf.output()  # type: ignore[no-any-return]
