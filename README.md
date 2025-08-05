# SlateHub

SlateHub is an open-source SaaS platform for connecting filmmakers, content creators, brands, producers, crew, talent, and influencers. It's a free, ad-free directory with semantic search and AI-assisted profiles, built as a monorepo.

## Tech Stack
- **Backend (api)**: Rust with Axum for REST API.
- **Database (db)**: SurrealDB with RocksDB for persistence.
- **Frontend (web)**: SvelteKit (client-side only, no SSR), semantic HTML with lightweight CSS framework for modern dark mode.
- **Storage**: Self-hosted MinIO for media.
- **AI**: Fastembed for embeddings.
- **Build/Run**: Makefile and Docker Compose.

## Setup
1. Clone the repo: `git clone <repo-url>`.
2. Install dependencies:
   - Rust: `cargo build` in api/.
   - Node: `npm install` in web/.
3. Run locally: `make run`.
4. Docker: `make docker-up`.

## Directories
- **api**: Rust backend.
- **db**: SurrealDB configs/migrations.
- **web**: SvelteKit frontend.

## Development
- Build: `make build`.
- Migrate DB: `make db-migrate`.
- Future: Static web files for CDN deployment.

## Contributing
Follow the iterative prompts in /prompts/ for building with AI assistance.

License: MIT (or as specified).
