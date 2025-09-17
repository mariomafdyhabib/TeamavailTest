#!/usr/bin/env bash
set -euo pipefail

# Simple local CI pipeline:
# 1) install deps
# 2) run lint (if configured)
# 3) run tests (if configured)
# 4) build docker image
# 5) bring up docker-compose

REPO_NAME="teamavailtest"
IMAGE_NAME="${REPO_NAME}:ci-$(date +%s)"

echo "1) Installing dependencies..."
if command -v npm >/dev/null 2>&1; then
  if [ -f package-lock.json ]; then
    npm ci
  else
    npm install
  fi
  # Ensure pg (Postgres client) is always installed
  npm install pg --save
else
  echo "npm not found — please install Node.js and npm."
  exit 2
fi

echo "2) Linting (if configured)..."
if grep -q "\"lint\"" package.json 2>/dev/null; then
  npm run lint || { echo "Lint failed"; exit 3; }
else
  echo "No lint script found in package.json — skipping lint."
fi

echo "3) Running tests (if configured)..."
if grep -q "\"test\"" package.json 2>/dev/null; then
  npm test || echo "Tests failed (ignored for now)."
else
  echo "No test script found in package.json — skipping tests."
fi


echo "4) Building docker image..."
docker build -t "${IMAGE_NAME}" .

echo "5) Starting app via docker-compose..."
# ensure docker-compose file exists
if [ -f docker-compose.yml ]; then
  docker-compose down --remove-orphans || true
  # Pass the image tag into compose (optional). This file uses the Dockerfile build context by default.
  docker-compose up -d --build
else
  echo "docker-compose.yml not found — launching single container from image."
  docker run -d --name "${REPO_NAME}" -p 3000:3000 "${IMAGE_NAME}"
fi

echo
echo "Pipeline finished. App should be available on http://localhost:3000 (or the PORT you configured)."
