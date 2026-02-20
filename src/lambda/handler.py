from typing import Any, TypedDict


class LambdaResponse(TypedDict):
    """Lambda handler response schema."""

    message: str
    input: dict[str, Any]


def build_response(event: dict[str, Any]) -> LambdaResponse:
    """Build a stable response payload from the input event."""
    return {
        "message": "Hello from Lambda!",
        "input": event,
    }


def handler(event: dict[str, Any], context: Any) -> LambdaResponse:
    """Handle Lambda invocation and return the response payload."""
    _ = context
    return build_response(event)
