#!/bin/bash
# Update config/themes.yml with Bird UI entries

set -e

THEMES_FILE="$1"

if [ -z "$THEMES_FILE" ]; then
    echo "Usage: $0 /path/to/themes.yml"
    exit 1
fi

echo "Updating themes.yml..."

# Add Bird UI themes if not present
if ! grep -q "bird-ui-auto" "$THEMES_FILE"; then
    {
        echo ""
        echo "# Bird UI Themes"
        echo "bird-ui-auto: styles/bird-ui-auto.scss"
        echo "bird-ui-accessible: styles/bird-ui-accessible.scss"
        echo "bird-ui-accessible-plus: styles/bird-ui-accessible-plus.scss"
    } >> "$THEMES_FILE"
fi

echo "✓ themes.yml updated"
