#!/bin/bash

# Pfad zu deinem Projekt
PROJECT_DIR="/path/to/timeloom"

# Wechsle in das Projektverzeichnis
cd $PROJECT_DIR

# Pull die neuesten Änderungen
git pull origin main

# Stoppe und entferne alle Container und Images
docker-compose -f backend/docker-compose.yml down
docker-compose -f frontend/docker-compose.yml down

# Entferne alle Images (Optional)
docker image prune -af

# Baue und starte Backend
cd $PROJECT_DIR/backend
docker-compose build
docker-compose up -d

# Baue und starte Frontend
cd $PROJECT_DIR/frontend
docker-compose build
docker-compose up -d
