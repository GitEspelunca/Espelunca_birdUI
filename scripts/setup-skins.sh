#!/bin/bash
# Setup Bird UI skins

set -e

MASTODON_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$MASTODON_PATH" ]; then
    echo "Usage: $0 /path/to/mastodon"
    exit 1
fi

echo "Setting up Bird UI skins..."

mkdir -p "${MASTODON_PATH}/app/javascript/skins/bird-ui"
cp -r "${SCRIPT_DIR}/../skins/bird-ui"/* "${MASTODON_PATH}/app/javascript/skins/bird-ui/"

echo "✓ Bird UI skins setup complete"
