#!/bin/bash
# Setup script for initial indexing of a codebase

set -e

echo "MCP Qdrant OpenAI - Initial Indexing Setup"
echo "=========================================="

# Check for required environment variables
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY environment variable is not set"
    echo "Please set it with: export OPENAI_API_KEY='your-api-key'"
    exit 1
fi

# Default values
QDRANT_URL="${QDRANT_URL:-http://localhost:6333}"
COLLECTION_NAME="${COLLECTION_NAME:-codebase}"
TARGET_DIR="${1:-.}"

# Check if target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

echo "Configuration:"
echo "  Target Directory: $TARGET_DIR"
echo "  Qdrant URL: $QDRANT_URL"
echo "  Collection Name: $COLLECTION_NAME"
echo ""

# Run the indexer
echo "Starting indexing process..."
python3 "$(dirname "$0")/indexer.py" "$TARGET_DIR"

echo ""
echo "Indexing complete! Your codebase is now searchable via the MCP server."
echo ""
echo "To use the MCP server, ensure your Claude Code configuration includes:"
echo '  "mcpServers": {'
echo '    "qdrant": {'
echo '      "command": "python3",'
echo '      "args": ["'$(realpath "$(dirname "$0")")/mcp_server_enhanced.py'"],'
echo '      "env": {'
echo '        "OPENAI_API_KEY": "your-api-key",'
echo '        "QDRANT_URL": "'$QDRANT_URL'",'
echo '        "COLLECTION_NAME": "'$COLLECTION_NAME'"'
echo '      }'
echo '    }'
echo '  }'