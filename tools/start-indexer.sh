#!/bin/bash
# Start the background indexer for a specific directory

if [ -z "$1" ]; then
    echo "Usage: $0 <directory-to-index>"
    echo "Example: $0 ~/GitHub/KinDash"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

# Update configuration
cat > "$(dirname "$0")/indexer.config.json" <<EOF
{
  "watchDir": "$TARGET_DIR",
  "collectionName": "${COLLECTION_NAME:-kindash-codebase-openai}",
  "openaiApiKey": "\${OPENAI_API_KEY}",
  "qdrantUrl": "${QDRANT_URL:-http://localhost:6333}",
  "includePatterns": [
    "**/*.ts",
    "**/*.tsx", 
    "**/*.js",
    "**/*.jsx",
    "**/*.json",
    "**/*.prisma",
    "**/*.md",
    "**/*.css"
  ],
  "excludePatterns": [
    "**/node_modules/**",
    "**/.git/**",
    "**/dist/**",
    "**/build/**",
    "**/coverage/**"
  ]
}
EOF

echo "Starting background indexer for: $TARGET_DIR"

# Make sure we have OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Warning: OPENAI_API_KEY is not set. The indexer may fail."
    echo "Please set: export OPENAI_API_KEY='your-key'"
fi

cd "$(dirname "$0")" && npm run indexer:start