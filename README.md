# Slatehub

**Slatehub** is an open‑source AI assisted film, TV, commercial, and social video production management tool built with a Svelte frontend and SurrealDB backend. It provides GitHub‑style collaboration with organizations, projects, and role‑based access control.

---

## Features

* Multi‑tenant support with `person`, `organization`, and `project` entities
* Role‑based access control: owner, admin, editor, viewer
* Secure signup/signin via Argon2‑hashed passwords
* Human‑friendly slugs for URLs
* Invitation and membership edges for social‑graph‑style collaboration
* Fully containerized with Docker
* Makefile‑driven workflow for development and seeding

---

## Prerequisites

* **Docker & Docker Compose**: to run SurrealDB in a container
* **SurrealDB CLI**: for schema import and raw SQL commands (install via Homebrew: `brew install surrealdb`)
* **Node.js & npm**: to run the Svelte frontend
* **GNU Make**: to use the provided Makefile

---

## Repository Structure

```
slatehub/
├── backend/
│   └── db/
│       ├── data/                # SurrealDB data files
│       └── schema.surql         # SurrealDB schema definitions
├── frontend/
│   └── web/
│       └── slatehub/           # Svelte application frontend
│           ├── src/
│           │   ├── lib/        # Library code
│           │   │   ├── components/  # UI components
│           │   │   ├── db/     # Database connection
│           │   │   └── styles/ # CSS stylesheets
│           │   ├── routes/     # Application routes
│           │   │   ├── debug/  # Debug utilities
│           │   │   ├── login/  # Authentication
│           │   │   ├── profile/ # User profile
│           │   │   └── signup/ # User registration
│           │   └── app.css     # Global styles
│           ├── AUTH.md         # Auth documentation
│           └── README.md       # Frontend docs
├── .env-example                # Environment template
├── docker-compose.yml          # SurrealDB container
├── Makefile                    # Development commands
└── README.md                   # This file
```

---

## Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-org/slatehub.git
   cd slatehub
   ```

2. **Create your environment file**

   ```bash
   cp .env-example .env
   # Then edit .env and fill in values:
   # SURREAL_USER, SURREAL_PASS, SURREAL_NS, SURREAL_DB
   # ADMIN_USERNAME, ADMIN_PASSWORD, ADMIN_EMAIL, ADMIN_ORG_NAME
   # FRONTEND_DIR
   ```

3. **Install dependencies**

   * **Frontend**:

     ```bash
     cd frontend/web/slatehub
     npm install
     # Set up frontend environment variables
     cp ../../.env .env
     echo "VITE_SURREAL_URL=http://localhost:8000" >> .env
     echo "VITE_SURREAL_NS=${SURREAL_NS:-seceda}" >> .env
     echo "VITE_SURREAL_DB=${SURREAL_DB:-core}" >> .env
     cd -
     ```

---

## Development Workflow

All commands assume you’re in the project root (`slatehub/`).

### Start the database

```bash
make start-db
```

Spins up the SurrealDB container on `localhost:8000`.

### Import the schema

```bash
make init-db
```

Runs `surreal import` to apply `schema.surql` against your namespace and database.

### Seed an admin user

1. **Seed the admin person** (signup):

   ```bash
   make seed-admin-person
   ```
2. **Seed the admin organization & membership**:

   ```bash
   make seed-admin-org
   ```

### Launch the frontend

```bash
make start-frontend
```

Starts the Svelte dev server, usually on `http://localhost:5173`.

The frontend includes:
- Complete authentication system (signup/signin)
- SurrealDB integration via client-side API
- Profile management
- Responsive design for desktop and mobile

### All‑in‑one for development

```bash
make dev
```

Runs `start-db`, `init-db`, and `start-frontend` in sequence.

---

## Maintenance

* **Stop the database (keep data)**:

  ```bash
  make stop-db
  ```
* **Erase all database data**:

  ```bash
  make erase-db
  ```
* **Tear down and rebuild everything**:

  ```bash
  make reset-db
  ```

---

## Contributing

Contributions are welcome! Please open issues or submit pull requests on GitHub.

---

## License

This project is open‑source under the MIT License. Feel free to use and modify it.
