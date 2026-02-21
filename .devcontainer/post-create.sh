#!/usr/bin/env bash
set -e

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Sync dependencies
uv sync --group dev

# Setup awslocal and tflocal wrappers
setup_wrapper() {
    local name=$1
    printf "#!/usr/bin/env bash\nuv run %s \"\$@\"\n" "$name" | sudo tee /usr/local/bin/"$name" >/dev/null
    sudo chmod +x /usr/local/bin/"$name"
}

setup_wrapper "awslocal"
setup_wrapper "tflocal"
