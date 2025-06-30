# MCP Qdrant OpenAI Server - Enhanced Edition

An enhanced Model Context Protocol (MCP) server that provides semantic search capabilities using Qdrant vector database and OpenAI embeddings. This fork includes additional tools for codebase indexing and background monitoring.

## Features

### Core MCP Server (`mcp_qdrant_server.py`)
- **Semantic Search**: Search your codebase using natural language queries
- **Vector Storage**: Store and retrieve code snippets with metadata
- **Collection Management**: Get information about your vector collections
- **MCP Protocol**: Full compatibility with Claude Desktop and other MCP clients

### Enhanced MCP Server (`mcp_server_enhanced.py`)
- All features of the core server plus:
- **Advanced Filtering**: Filter search results by file type, path patterns
- **Batch Operations**: Process multiple queries efficiently
- **Better Error Handling**: Robust error messages and recovery

### Codebase Indexer (`indexer.py`)
- **Smart Code Analysis**: Understands React components, TypeScript interfaces, API endpoints
- **OpenAI Embeddings**: Uses text-embedding-3-small for superior semantic understanding
- **Selective Indexing**: Configurable file extensions and exclusion patterns
- **Batch Processing**: Efficient indexing of large codebases
- **Incremental Updates**: Index only changed files

### Background Tools (Optional)
Located in the `tools/` directory:
- **Background Indexer**: Watches for file changes and automatically updates the index
- **Control Interface**: Start, stop, and monitor the indexing process

## Installation

### Basic Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mcp-qdrant-openai.git
cd mcp-qdrant-openai
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
export OPENAI_API_KEY="your-openai-api-key"
export QDRANT_URL="http://localhost:6333"  # Or your Qdrant instance URL
export COLLECTION_NAME="my-codebase"        # Your collection name
```

### Optional: Background Tools Setup

If you want to use the background indexing tools:

```bash
cd tools
npm install
```

## Usage

### MCP Server

Configure in Claude Desktop's `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "qdrant": {
      "command": "python",
      "args": ["/path/to/mcp-qdrant-openai/mcp_server_enhanced.py"],
      "env": {
        "OPENAI_API_KEY": "your-key",
        "QDRANT_URL": "http://localhost:6333",
        "COLLECTION_NAME": "my-codebase"
      }
    }
  }
}
```

### Indexing Your Codebase

#### One-time indexing:
```bash
python indexer.py /path/to/your/project
```

#### Index specific file types:
```bash
python indexer.py /path/to/your/project --extensions .ts .tsx .js
```

#### Background indexing (optional):
```bash
cd tools
node background-indexer.js start /path/to/your/project
node indexer-control.js status  # Check status
node indexer-control.js stop    # Stop indexing
```

### Using in Claude Desktop

Once configured, you can use these commands in Claude Desktop:

- **Search**: "Find authentication implementation"
- **Filter**: "Show me all React components in the auth module"
- **Analyze**: "What error handling patterns are used in the API?"

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OPENAI_API_KEY` | Your OpenAI API key | Required |
| `QDRANT_URL` | Qdrant server URL | `http://localhost:6333` |
| `QDRANT_API_KEY` | Qdrant API key (if using cloud) | None |
| `COLLECTION_NAME` | Vector collection name | `codebase` |
| `OPENAI_MODEL` | Embedding model | `text-embedding-3-small` |
| `BATCH_SIZE` | Indexing batch size | `100` |
| `MAX_FILE_SIZE` | Max file size to index (bytes) | `1048576` (1MB) |

### Indexer Configuration

Edit these constants in `indexer.py`:

```python
VALID_EXTENSIONS = {'.ts', '.tsx', '.js', '.jsx', '.py', ...}
EXCLUDE_DIRS = {'node_modules', '.git', 'dist', ...}
```

## Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│  Claude Desktop │────▶│  MCP Server  │────▶│   Qdrant    │
└─────────────────┘     └──────────────┘     └─────────────┘
                               │                      ▲
                               ▼                      │
                        ┌──────────────┐              │
                        │   Indexer    │──────────────┘
                        └──────────────┘
                               ▲
                               │
                        ┌──────────────┐
                        │  Background  │ (Optional)
                        │   Monitor    │
                        └──────────────┘
```

## Troubleshooting

### Common Issues

1. **"OpenAI API key not found"**
   - Ensure `OPENAI_API_KEY` is set in your environment
   - Check that the key is valid and has access to embeddings API

2. **"Failed to connect to Qdrant"**
   - Verify Qdrant is running on the specified URL
   - Check firewall settings if using remote Qdrant

3. **"Collection not found"**
   - Run the indexer first to create and populate the collection
   - Check `COLLECTION_NAME` matches between indexer and server

### Debug Mode

Enable detailed logging:
```bash
export LOG_LEVEL=DEBUG
python mcp_server_enhanced.py
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Acknowledgments

- Original MCP Qdrant server by [username]
- OpenAI for embeddings API
- Qdrant team for the vector database
- Anthropic for the MCP protocol