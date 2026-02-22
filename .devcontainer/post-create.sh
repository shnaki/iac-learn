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

# Ensure LocalStack environment variables are set for all shell sessions.
# docker-compose.workspace.yml also sets these at container level, but shell
# profiles guarantee they are available in all terminal contexts (login/non-login).
sudo tee /etc/profile.d/localstack.sh > /dev/null << 'ENVEOF'
export TF_VAR_localstack_endpoint=http://localstack:4566
export LOCALSTACK_HOST=localstack:4566
export LOCALSTACK_HOSTNAME=localstack
ENVEOF

if ! grep -q "TF_VAR_localstack_endpoint" ~/.bashrc; then
    cat >> ~/.bashrc << 'ENVEOF'
# LocalStack Dev Container environment
export TF_VAR_localstack_endpoint=http://localstack:4566
export LOCALSTACK_HOST=localstack:4566
export LOCALSTACK_HOSTNAME=localstack
ENVEOF
fi
