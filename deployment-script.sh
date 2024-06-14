#!/bin/bash

# Logging Funktion
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> /var/log/deployment.log
}

log "Deployment script started"

# Pfad zu deinem Projekt
PROJECT_DIR="/path/to/timeloom"
PROJECT_NAME="timeloom"

# Wechsle in das Projektverzeichnis
cd $PROJECT_DIR || { log "Failed to change directory to $PROJECT_DIR"; exit 1; }

# Pull die neuesten Änderungen
if git pull origin main; then
    log "Pulled latest changes successfully"
else
    log "Failed to pull latest changes"
    exit 1
fi

# Stoppe und entferne alle Container und Images, die mit Timeloom zu tun haben
docker-compose -f backend/docker-compose.yml down
docker-compose -f frontend/docker-compose.yml down

# Entferne alle Timeloom-bezogenen Images
docker images | grep $PROJECT_NAME | awk '{print $3}' | xargs docker rmi -f

# Baue und starte Backend
cd $PROJECT_DIR/backend || { log "Failed to change directory to backend"; exit 1; }
if docker-compose build && docker-compose up -d; then
    log "Backend built and started successfully"
else
    log "Failed to build and start backend"
    exit 1
fi

# Baue und starte Frontend
cd $PROJECT_DIR/frontend || { log "Failed to change directory to frontend"; exit 1; }
if docker-compose build && docker-compose up -d; then
    log "Frontend built and started successfully"
else
    log "Failed to build and start frontend"
    exit 1
fi

log "Deployment script completed"
