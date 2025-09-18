# TeamAvailTest - Local CI/CD & Dockerization

This repository contains **Team Availability Tracker**, a small app to manage and view team availability. The project includes a **local CI/CD pipeline**, **Dockerfile**, and **docker-compose** setup to run the app locally.

## What I Did

- Built a **Node.js + Express backend** connected to PostgreSQL for storing and retrieving availability history.
- Created a **dynamic frontend** to render employee availability, using JSON data files (`names.json`, `selection.json`, `status.json`) and data fetched from the database.
- Implemented **dropdowns** for selecting weeks and daily statuses, with color-coded visual cues.
- Created a **local Bash-based CI/CD script (`ci.sh`)** that automates building, testing, and running the Docker containers.
- Set up **Docker and Docker Compose** to containerize the app (`teamavail-app`) and database (`teamavail-db`) for easy local deployment.
- Configured **volumes** to persist PostgreSQL data and serve frontend JSON files correctly.
- Added **API endpoints**:
  - `GET /get-history` → fetch the latest history from PostgreSQL.
  - `POST /save-history` → save updated availability to the database.

## Error Handling & Debugging

- **Empty History Check:** The backend rejects empty data to prevent accidental overwrites.
- **Frontend Fetch Errors:** edit historyRes to fetch dynamic history (/get-history)
- **Database Errors:** All DB queries are wrapped in `try/catch` blocks with descriptive logging.
- **Network & Docker Issues:** 
  - We ensure Docker volumes are correctly mapped (`./input` for JSON files, `postgres_data` for DB persistence).
  - For Docker Hub connection errors, increase timeouts or switch to a different Node base image (e.g., `node:18-bullseye`).
- **Edit server.js** The backend send data to file instead of postgress.

## Requirements

- Docker & Docker Compose
- Node.js (for local testing/linting)
- bash (for `ci.sh`)

## Quick Start (Recommended)

1. Clone the repo:

   ```bash
   git clone https://github.com/ge0rgeK/TeamavailTest.git
   cd TeamavailTest
   chmod +x ci.sh
   ./ci.sh

## URL
http://localhost:3000/get-history

http://localhost:3000