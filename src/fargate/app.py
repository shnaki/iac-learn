def create_message() -> str:
    """Return the default Fargate greeting message."""
    return "Hello from Fargate!"


def main() -> None:
    """Run the Fargate application entrypoint."""
    print(create_message())


if __name__ == "__main__":
    main()
