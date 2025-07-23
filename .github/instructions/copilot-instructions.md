# Copilot Instructions - n8n AI Automation Stack

## Project Overview

This is a self-hosted n8n workflow automation platform with an integrated AI stack for document processing, embedding, and intelligent email assistance. The architecture combines four containerized services for a complete RAG (Retrieval-Augmented Generation) solution.

## Architecture & Service Dependencies

### Core Services Stack
- **n8n**: Workflow automation engine (port 5678) with PostgreSQL backend
- **PostgreSQL**: Primary database with custom user provisioning via `init-data.sh`
- **Ollama**: Local LLM server (port 11435→11434) for chat and embedding models
- **Qdrant**: Vector database (port 6333/6334) for semantic search and RAG workflows

### Critical Networking
All services communicate via `n8n-network` bridge. Internal URLs:
- n8n → Ollama: `http://ollama:11434`
- n8n → Qdrant: `http://qdrant:6333`
- n8n → PostgreSQL: `postgres:5432`

## Configuration Management

### Environment Variables Pattern
Configuration follows dual-level security:
- `.env` file for service credentials (never commit with real values)
- Docker environment variables mapped in `docker-compose.yml`
- Critical security keys: `N8N_ENCRYPTION_KEY`, `POSTGRES_PASSWORD`, `N8N_BASIC_AUTH_PASSWORD`

### Container Orchestration Scripts
- `start.sh`: Validates `.env`, warns about default passwords, starts stack
- `stop.sh`: Graceful shutdown preserving volumes
- `clean.sh`: Removes containers but preserves data volumes
- `setup-ollama.sh`: Interactive model installation with `.env` updates

## AI Model Management

### Embedding Strategy
- **Production**: Use `nomic-embed-text` (768 dimensions, CPU-optimized)
- **Vector dimensions**: Configure Qdrant collections to match model output
- **Model switching**: Update both `.env` and recreate Qdrant collections

### Chat Model Selection
- **Lightweight**: `qwen2.5:3b` (best tool support, multilingual)
- **Ultra-light**: `gemma2:2b` (minimal resource usage)
- **Important**: Models are containerized in Ollama, not n8n

## Development Workflows

### Adding New AI Models
1. Use `setup-ollama.sh` for interactive selection
2. Verify model compatibility: embedding models ≠ chat models
3. Update Qdrant vector dimensions to match embedding model
4. Test with `test-ollama.sh` before production use

### Database Operations
```bash
# Backup workflows and data
podman compose exec postgres pg_dump -U n8n n8n > backup.sql

# Check volume sizes
docker compose exec postgres du -sh /var/lib/postgresql/data

# Restore after container rebuild
podman compose exec -T postgres psql -U n8n n8n < backup.sql
```

### Vector Store Management
- Collections are auto-created via `qdrant-config.yaml`
- **Dimension mismatch errors**: Recreate collection with correct dimensions
- Monitor via Qdrant dashboard: `http://localhost:6333/dashboard`

## Security & Production Considerations

### Mandatory Security Steps
1. **Never use default passwords** - `start.sh` validates this
2. **Generate encryption keys**: `./generate-key.sh` for `N8N_ENCRYPTION_KEY`
3. **Credential persistence**: Changing encryption key loses all n8n credentials

### Container Runtime Preferences
- **Primary**: Podman Compose (rootless, more secure)
- **Fallback**: Docker Compose (scripts auto-detect)
- **Resource allocation**: Ollama reserves 2GB RAM minimum

## Workflow Patterns

### Included Templates (`workflows/`)
- **Indexation.json**: Document embedding via form upload
- **Search in Index.json**: RAG-powered chat interface with vector search
- **Mail.json**: Email processing with AI classification and response generation

### AI Integration Patterns
- **Tool usage**: Agents with vector store tools for knowledge retrieval
- **Memory management**: Session-based conversation history
- **Structured outputs**: JSON parsing for email classification
- **Multi-model flows**: Separate embedding and chat models in same workflow

## Debugging & Troubleshooting

### Common Issues
- **Vector dimension errors**: Model/Qdrant collection mismatch
- **Ollama connectivity**: Check internal Docker networking (`ollama:11434`)
- **n8n startup failures**: Verify PostgreSQL health checks pass first
- **Missing models**: Use `setup-ollama.sh` to install required models

### Monitoring Commands
```bash
# Service health
podman compose ps
podman compose logs -f n8n

# AI model status
podman compose exec ollama ollama list

# Vector store health
curl http://localhost:6333/health
```

## Development Guidelines

When modifying this stack:
- **Preserve volume mounts** for data persistence
- **Update both internal and external port mappings** when adding services
- **Test AI workflows end-to-end** after model changes
- **Document vector dimensions** when adding new embedding models
- **Use structured prompts** following examples in `ollama-prompts.md`

The architecture prioritizes local deployment, data privacy, and CPU-optimized AI models suitable for self-hosted environments.
