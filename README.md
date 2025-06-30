# MCP Qdrant Server with OpenAI Embeddings

[![smithery badge](https://smithery.ai/badge/@amansingh0311/mcp-qdrant-openai)](https://smithery.ai/server/@amansingh0311/mcp-qdrant-openai)

A Model Context Protocol (MCP) server that provides semantic search capabilities using Qdrant vector database and OpenAI embeddings.

## Features

- **Semantic Search** - Find code and documentation using natural language queries
- **OpenAI Embeddings** - Uses `text-embedding-3-small` for high-quality 1536-dimensional vectors
- **Background Indexing** - Automatically index files as they change
- **Advanced Filtering** - Filter by file type, path, and metadata
- **MCP Integration** - Works seamlessly with Claude Code and other MCP clients
- **Enhanced Server** - Additional features like point queries and collection management

## Prerequisites

- Python 3.10+ installed
- Qdrant instance running (local or remote)
- OpenAI API key
- Node.js 14+ (for background indexing tools)

## Installation

### Installing via Smithery

To install Qdrant Vector Search Server for Claude Desktop automatically via [Smithery](https://smithery.ai/server/@amansingh0311/mcp-qdrant-openai):

```bash
npx -y @smithery/cli install @amansingh0311/mcp-qdrant-openai --client claude
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/steiner385/mcp-qdrant-openai.git
   cd mcp-qdrant-openai
   ```

2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Install Node.js dependencies (for background indexing):
   ```bash
   cd tools && npm install && cd ..
   ```

## Configuration

Set the following environment variables:

- `OPENAI_API_KEY`: Your OpenAI API key (required)
- `QDRANT_URL`: URL to your Qdrant instance (default: "http://localhost:6333")
- `QDRANT_API_KEY`: Your Qdrant API key (if applicable)
- `COLLECTION_NAME`: Default collection name for indexing

## Quick Start

### 1. Index Your Codebase

Use the setup script for interactive configuration:

```bash
./setup_indexing.sh /path/to/your/project
```

Or use the indexer directly:

```bash
python3 indexer.py /path/to/your/project
```

### 2. Configure Claude Code

Add to your `~/.claude.json`:

```json
{
  "mcpServers": {
    "qdrant": {
      "command": "python3",
      "args": ["/path/to/mcp-qdrant-openai/mcp_server_enhanced.py"],
      "env": {
        "QDRANT_URL": "http://localhost:6333",
        "COLLECTION_NAME": "your-collection-name",
        "OPENAI_API_KEY": "your-api-key"
      }
    }
  }
}
```

### 3. Start Background Indexing (Optional)

For automatic indexing of file changes:

```bash
cd tools
npm run indexer:start:full  # Index all files and monitor changes
```

## Available Tools

### Basic MCP Server (`mcp_qdrant_server.py`)

- **query_collection** - Search using semantic similarity
  - `collection_name`: Name of the Qdrant collection
  - `query_text`: Natural language search query
  - `limit`: Maximum results (default: 5)
  - `model`: OpenAI model (default: text-embedding-3-small)

- **list_collections** - List all available collections

- **collection_info** - Get collection statistics
  - `collection_name`: Name of the collection

### Enhanced MCP Server (`mcp_server_enhanced.py`)

The enhanced server includes simplified tool names and integrated indexing controls:

#### Search Tools
- **search** - Search for code using semantic similarity
  - `query`: Search query text
  - `limit`: Maximum results (default: 10)
  - `filter`: Optional metadata filters

- **store** - Store code snippet with embeddings
  - `content`: Content to store
  - `metadata`: Metadata for the content
  - `id`: Optional unique ID

- **collection_info** - Get information about the collection

#### Indexing Control Tools (New!)
- **index_directory** - Index all files in a directory
  - `directory_path`: Path to directory to index
  - `collection_name`: Optional collection name

- **start_background_indexing** - Start file monitoring and indexing
  - `directory_path`: Directory to monitor
  - `initial_index`: Index all files on startup (default: false)

- **stop_background_indexing** - Stop the background indexer

- **indexer_status** - Get current indexer status and statistics

- **pause_indexing** - Pause indexing (keeps monitoring files)

- **resume_indexing** - Resume paused indexing

## Indexing Tools

### Manual Indexing

```bash
# Index with default settings
python3 indexer.py /path/to/project

# Custom collection name
COLLECTION_NAME=my-project python3 indexer.py /path/to/project

# Specific file types only
python3 indexer.py /path/to/project --extensions .py .js
```

### Background Indexing

The `tools/` directory contains Node.js tools for continuous monitoring:

```bash
cd tools

# Start monitoring (changes only)
npm run indexer:start

# Start with full initial index
npm run indexer:start:full

# Check status
npm run indexer:status

# Watch live progress
npm run indexer:watch

# Stop indexing
npm run indexer:stop
```

See [tools/README.md](tools/README.md) for detailed documentation.

## File Types Supported

Default included patterns:
- TypeScript: `*.ts`, `*.tsx`
- JavaScript: `*.js`, `*.jsx`
- Python: `*.py`
- JSON: `*.json`
- Markdown: `*.md`
- Prisma: `*.prisma`
- CSS: `*.css`

Excluded by default:
- `node_modules/`
- `.git/`
- `dist/`, `build/`
- Test files: `*.test.*`, `*.spec.*`
- Coverage reports
- Hidden files

## Example Usage in Claude Code

Once configured, you can use natural language queries:

### Search Operations
```
What collections are available in my Qdrant database?

Search for authentication implementation in the codebase

Show me all React components that handle user input

Find the database schema definitions

Where is error handling implemented?
```

### Indexing Operations (Enhanced Server)
```
Index all files in /home/user/my-project

Start monitoring /home/user/my-project for file changes

Start background indexing for /home/user/my-project with initial full index

Check the status of the background indexer

Pause the background indexing

Resume the background indexing

Stop the background indexer
```

The indexing tools allow you to control the entire indexing process without leaving Claude Code!

## Cost Considerations

OpenAI embedding costs:
- text-embedding-3-small: $0.02 per 1M tokens
- text-embedding-3-large: $0.13 per 1M tokens

Typical usage:
- Initial indexing of 1000 files: ~$0.01-0.02
- Incremental updates: negligible

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│   MCP Server    │────▶│     Qdrant      │
│  (MCP Client)   │     │  (Python)       │     │  Vector DB      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐     ┌─────────────────┐
                        │  OpenAI API     │     │  Background     │
                        │  (Embeddings)   │     │  Indexer (Node) │
                        └─────────────────┘     └─────────────────┘
```

## Troubleshooting

### MCP Server Issues

1. **Server won't start**
   - Verify Qdrant is running: `curl http://localhost:6333`
   - Check OPENAI_API_KEY is set correctly
   - Review Claude Code logs for errors

2. **No search results**
   - Verify collection exists: use list_collections tool
   - Check collection has documents: use collection_info tool
   - Ensure query text is descriptive

### Indexing Issues

1. **Indexing fails**
   - Verify OpenAI API key is valid
   - Check network connectivity to Qdrant
   - Look for specific error messages

2. **Files not indexed**
   - Check file size (<1MB limit by default)
   - Verify file extensions are included
   - Check exclude patterns

### Background Indexer Issues

See [tools/README.md](tools/README.md#troubleshooting) for detailed troubleshooting.

## Advanced Configuration

### Custom File Patterns

Create `indexer.config.json` in the tools directory:

```json
{
  "includePatterns": ["**/*.vue", "**/*.svelte"],
  "excludePatterns": ["**/temp/**"],
  "maxFileSize": 2097152
}
```

### Collection Settings

Collections use cosine similarity with 1536 dimensions for OpenAI embeddings.

To use different models, set the appropriate dimensions:
- text-embedding-3-small: 1536 dimensions
- text-embedding-3-large: 3072 dimensions
- text-embedding-ada-002: 1536 dimensions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built for [Claude Code](https://claude.ai/code) by Anthropic
- Uses [Qdrant](https://qdrant.tech/) vector database
- Embeddings powered by [OpenAI](https://openai.com/)
- Original MCP server by [@amansingh0311](https://github.com/amansingh0311)
- Enhanced version with background indexing by [@steiner385](https://github.com/steiner385)