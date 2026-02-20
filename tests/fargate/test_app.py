from importlib import util
from pathlib import Path
from types import ModuleType

import pytest


def _load_fargate_module() -> ModuleType:
    module_path = Path(__file__).resolve().parents[2] / "src" / "fargate" / "app.py"
    spec = util.spec_from_file_location("fargate_app", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError("Failed to load fargate app module.")

    module = util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_create_message_returns_expected_text() -> None:
    module = _load_fargate_module()

    assert module.create_message() == "Hello from Fargate!"


def test_main_prints_expected_message(capsys: pytest.CaptureFixture[str]) -> None:
    module = _load_fargate_module()

    module.main()

    captured = capsys.readouterr()
    assert captured.out == "Hello from Fargate!\n"
