# Qdrant Background Indexer Tools

This directory contains tools for background indexing and monitoring of files for the MCP Qdrant OpenAI server.

## Features

- **Real-time file monitoring** - Automatically indexes files when they change
- **Batch processing** - Efficiently processes multiple files in batches
- **Persistent state** - Remembers indexed files across restarts
- **Error recovery** - Retries failed indexing operations
- **Live monitoring** - Watch indexing progress in real-time
- **Pause/Resume** - Control indexing without stopping the monitor

## Installation

```bash
cd tools
npm install
```

## Quick Start

### Start background indexing (monitor changes only)
```bash
npm run indexer:start
```

### Start with initial full index
```bash
npm run indexer:start:full
```

### Using the shell script
```bash
./start-indexer.sh ~/path/to/project
```

## Available Commands

### NPM Scripts

- `npm run indexer:start` - Start the background indexer (monitors changes only)
- `npm run indexer:start:full` - Start and index all existing files
- `npm run indexer:stop` - Stop the background indexer
- `npm run indexer:restart` - Restart the indexer
- `npm run indexer:status` - Show current status
- `npm run indexer:watch` - Watch live status updates
- `npm run indexer:pause` - Pause indexing (keeps monitoring)
- `npm run indexer:resume` - Resume indexing
- `npm run indexer:reindex` - Clear and re-index all files
- `npm run indexer:clear` - Clear all indexer data
- `npm run indexer:logs` - Tail indexer logs

### Direct Control

```bash
node indexer-control.js <command> [options]
```

Commands:
- `start [--initial-index]` - Start indexer with optional full initial indexing
- `stop` - Stop the indexer
- `restart` - Restart the indexer
- `status` - Show current status
- `pause` - Pause indexing
- `resume` - Resume indexing
- `reindex` - Clear and re-index everything
- `clear` - Clear all data
- `logs` - Tail logs
- `watch` - Watch live status

## Configuration

The indexer uses `indexer.config.json` for configuration:

```json
{
  "watchDir": "/path/to/project",
  "collectionName": "kindash-codebase-openai",
  "openaiApiKey": "${OPENAI_API_KEY}",
  "qdrantUrl": "http://localhost:6333",
  "includePatterns": ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"],
  "excludePatterns": ["**/node_modules/**", "**/.git/**"]
}
```

## File Patterns

### Included by default:
- TypeScript files (`.ts`, `.tsx`)
- JavaScript files (`.js`, `.jsx`)
- JSON files (`.json`)
- Prisma schema files (`.prisma`)
- Markdown files (`.md`)
- CSS files (`.css`)

### Excluded by default:
- `node_modules/`
- `.git/`
- `dist/`
- `build/`
- `coverage/`
- `.next/`
- Test files (`*.test.*`, `*.spec.*`)

## State Files

The indexer maintains several state files in the tools directory:

- `.qdrant-indexer.pid` - Process ID of running indexer
- `.qdrant-indexer.log` - Detailed logs
- `.qdrant-indexing-status.json` - Current status and statistics
- `.qdrant-indexed-files.json` - List of indexed files
- `.qdrant-indexing-queue.json` - Files queued for indexing

## Environment Variables

- `OPENAI_API_KEY` - Required for generating embeddings
- `QDRANT_URL` - Qdrant server URL (default: http://localhost:6333)
- `COLLECTION_NAME` - Collection name for storing embeddings

## Monitoring

### Watch live status:
```bash
npm run indexer:watch
```

This shows:
- Running status
- Total files being monitored
- Number of indexed files
- Failed indexing attempts
- Queue size
- Processing status
- Recent activity

### View logs:
```bash
npm run indexer:logs
# or
tail -f .qdrant-indexer.log
```

## Troubleshooting

### Indexer won't start
1. Check if another instance is running: `npm run indexer:status`
2. Check for stale PID file: `rm .qdrant-indexer.pid`
3. Ensure OPENAI_API_KEY is set
4. Verify Qdrant is running at the configured URL

### Files not being indexed
1. Check file patterns in configuration
2. Verify files aren't in excluded directories
3. Check logs for errors: `npm run indexer:logs`
4. Ensure the indexer isn't paused: `npm run indexer:status`

### High memory usage
1. Reduce batch size in the configuration
2. Increase the batch delay
3. Consider excluding large files

## Architecture

The background indexer consists of:

1. **File Watcher** - Uses chokidar to monitor file changes
2. **Queue Manager** - Batches files for efficient processing
3. **Indexer Process** - Calls the Python indexer script
4. **State Manager** - Maintains persistent state across restarts
5. **Control Interface** - Manages the indexer process

## Performance

- Processes files in batches of 10 (configurable)
- 2-second delay between batches to avoid overload
- Debounces rapid file changes (500ms)
- Skips files larger than 1MB
- Maintains indexed file list to avoid re-indexing