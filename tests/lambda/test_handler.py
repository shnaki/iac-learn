from importlib import util
from pathlib import Path
from types import ModuleType


def _load_handler_module() -> ModuleType:
    module_path = Path(__file__).resolve().parents[2] / "src" / "lambda" / "handler.py"
    spec = util.spec_from_file_location("lambda_handler", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError("Failed to load lambda handler module.")

    module = util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_handler_returns_expected_message_and_input() -> None:
    module = _load_handler_module()
    event = {"hello": "world"}

    result = module.handler(event, context=None)

    assert result["message"] == "Hello from Lambda!"
    assert result["input"] == event


def test_handler_accepts_empty_event() -> None:
    module = _load_handler_module()

    result = module.handler({}, context=None)

    assert result["message"] == "Hello from Lambda!"
    assert result["input"] == {}
