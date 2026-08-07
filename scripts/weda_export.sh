#!/usr/bin/env bash

# File paths in current working directory
ENV_PATH=".env"
COMPOSE_PATH="docker-compose.yml"
EXPORT_DIR="weda_export"
JSON_PATH="$EXPORT_DIR/.env.json"
B64_PATH="$EXPORT_DIR/docker-compose.yml.base64"

# Create export directory if it doesn't exist
mkdir -p "$EXPORT_DIR"

if [ ! -f "$ENV_PATH" ]; then
    echo "Error: $ENV_PATH not found in the current directory." >&2
    exit 1
fi

if [ ! -f "$COMPOSE_PATH" ]; then
    echo "Error: $COMPOSE_PATH not found in the current directory." >&2
    exit 1
fi

# 1. Convert .env to .env.json using python3
python3 - "$ENV_PATH" "$JSON_PATH" << 'EOF'
import sys
import json
import os

env_filepath = sys.argv[1]
json_filepath = sys.argv[2]

data = {}
with open(env_filepath, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        # Skip empty lines and full comments
        if not line or line.startswith('#'):
            continue
        
        # Must contain '='
        if '=' not in line:
            continue
        
        key, val = line.split('=', 1)
        key = key.strip()
        
        # Remove inline comments (handling double and single quotes)
        val_clean = ""
        in_double_quote = False
        in_single_quote = False
        for char in val:
            if char == '"' and not in_single_quote:
                in_double_quote = not in_double_quote
            elif char == "'" and not in_double_quote:
                in_single_quote = not in_single_quote
            elif char == '#' and not in_double_quote and not in_single_quote:
                break
            val_clean += char
        
        val = val_clean.strip()
        
        # Strip outer quotes if they match
        if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
            val = val[1:-1]
            data[key] = val
            continue
        
        # Parse boolean values
        val_lower = val.lower()
        if val_lower == 'true':
            data[key] = True
        elif val_lower == 'false':
            data[key] = False
        else:
            # Parse integer or float, fallback to string
            try:
                data[key] = int(val)
            except ValueError:
                try:
                    data[key] = float(val)
                except ValueError:
                    data[key] = val

with open(json_filepath, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Successfully converted {env_filepath} to {json_filepath}")
EOF

# 2. Base64 encode docker-compose.yml
if command -v base64 >/dev/null 2>&1; then
    base64 -w 0 "$COMPOSE_PATH" > "$B64_PATH"
else
    python3 -c "import base64; open('$B64_PATH', 'wb').write(base64.b64encode(open('$COMPOSE_PATH', 'rb').read()))"
fi

echo "Successfully encoded $COMPOSE_PATH to $B64_PATH"
