#!/bin/bash
# Setup Bird UI flavour

set -e

MASTODON_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$MASTODON_PATH" ]; then
    echo "Usage: $0 /path/to/mastodon"
    exit 1
fi

echo "Setting up Bird UI flavour..."

mkdir -p "${MASTODON_PATH}/app/javascript/flavours/bird-ui"
cp -r "${SCRIPT_DIR}/../flavour/bird-ui"/* "${MASTODON_PATH}/app/javascript/flavours/bird-ui/"

echo "✓ Bird UI flavour setup complete"
