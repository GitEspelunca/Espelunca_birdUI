#!/bin/bash
# Update locale files with Bird UI entries

set -e

MASTODON_PATH="$1"

if [ -z "$MASTODON_PATH" ]; then
    echo "Usage: $0 /path/to/mastodon"
    exit 1
fi

echo "Updating locales..."

# English
EN_LOCALE="${MASTODON_PATH}/config/locales/en.yml"
if [ -f "$EN_LOCALE" ] && ! grep -q "bird-ui-auto:" "$EN_LOCALE"; then
    sed -i '/^  themes:/a\    bird-ui-auto: Mastodon Bird UI\n    bird-ui-accessible: Mastodon Bird UI (Accessible)\n    bird-ui-accessible-plus: Mastodon Bird UI (Accessible Plus)' "$EN_LOCALE" 2>/dev/null || true
fi

# Portuguese
PT_LOCALE="${MASTODON_PATH}/config/locales/pt.yml"
if [ -f "$PT_LOCALE" ] && ! grep -q "bird-ui-auto:" "$PT_LOCALE"; then
    sed -i '/^  themes:/a\    bird-ui-auto: Mastodon Bird UI\n    bird-ui-accessible: Mastodon Bird UI (Acessível)\n    bird-ui-accessible-plus: Mastodon Bird UI (Acessível Plus)' "$PT_LOCALE" 2>/dev/null || true
fi

echo "✓ Locales updated"
