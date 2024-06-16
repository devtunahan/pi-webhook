#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to handle errors
error_exit()
{
    echo "$1" 1>&2
    exit 1
}

REMOTE_HOST="pi@192.168.68.114"
REMOTE_DIR="~/pi-webhook"

echo "Beende den Container..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose down" || error_exit "Fehler beim Beenden des Containers."

echo "Ziehe die neuesten Änderungen vom Git-Repository..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && git pull" || error_exit "Fehler beim Ausführen von 'git pull'."

echo "Baue das Docker-Image neu..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose build" || error_exit "Fehler beim Bauen des Docker-Images."

echo "Starte den Container erneut..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose up -d" || error_exit "Fehler beim Starten des Containers."

echo "Redeployment abgeschlossen."
