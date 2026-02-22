#!/bin/bash
# Get Yandex OAuth token for Direct API v5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../config"
ENV_FILE="$CONFIG_DIR/.env"

CLIENT_ID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --client-id|-i) CLIENT_ID="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$CLIENT_ID" ]]; then
    echo "Usage: get_token.sh --client-id YOUR_CLIENT_ID"
    echo ""
    echo "Get client_id at: https://oauth.yandex.ru/client/new"
    echo "Required permissions: Яндекс.Директ (direct:api)"
    exit 1
fi

echo "=== Yandex Direct OAuth Token Setup ==="
echo ""
echo "Step 1: Open this URL in your browser:"
echo ""
echo "  https://oauth.yandex.ru/authorize?response_type=token&client_id=$CLIENT_ID"
echo ""
echo "Step 2: Authorize the application"
echo ""
echo "Step 3: Copy the token from the redirect URL:"
echo "  https://oauth.yandex.ru/#access_token=YOUR_TOKEN_HERE&..."
echo ""
echo -n "Paste your token here: "
read -rs TOKEN
echo ""

if [[ -z "$TOKEN" ]]; then
    echo "Error: No token provided"
    exit 1
fi

echo ""
echo "Token received!"
echo ""

# Save to .env
if [[ -f "$ENV_FILE" ]]; then
    # Replace token safely (avoid sed issues with special chars in tokens)
    grep -v "^YANDEX_DIRECT_TOKEN=" "$ENV_FILE" > "$ENV_FILE.tmp" || true
    echo "YANDEX_DIRECT_TOKEN=$TOKEN" >> "$ENV_FILE.tmp"
    mv "$ENV_FILE.tmp" "$ENV_FILE"
    echo "Updated token in: $ENV_FILE"
else
    echo "YANDEX_DIRECT_TOKEN=$TOKEN" > "$ENV_FILE"
    echo "Created: $ENV_FILE"
fi

echo ""
echo "Verifying token..."
echo ""

bash "$SCRIPT_DIR/check_connection.sh"
