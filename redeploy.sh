#!/bin/bash

# Name des Docker Compose Service, der den Webhook-Server enthält
SERVICE_NAME="webhook-server"

# Docker Compose Datei
COMPOSE_FILE="docker-compose.yml"

echo "Beende den Container..."
docker-compose -f $COMPOSE_FILE down

echo "Lösche das Docker-Image..."
docker rmi ${SERVICE_NAME}

echo "Baue das Docker-Image neu..."
docker-compose -f $COMPOSE_FILE build

echo "Starte den Container erneut..."
docker-compose -f $COMPOSE_FILE up -d

echo "Redeployment abgeschlossen."
