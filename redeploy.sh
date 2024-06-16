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

echo "Beende den aktuellen Container..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose stop webhook-server" || error_exit "Fehler beim Beenden des Containers."

echo "Ziehe die neuesten Änderungen vom Git-Repository..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && git pull" || error_exit "Fehler beim Ausführen von 'git pull'."

echo "Setze Berechtigungen für 'redeploy.sh'..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && chmod +x redeploy.sh" || error_exit "Fehler beim Setzen der Berechtigungen für 'redeploy.sh'."

echo "Baue das neue Docker-Image..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose build webhook-server-new" || error_exit "Fehler beim Bauen des Docker-Images."

echo "Starte den neuen Container..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose up -d webhook-server-new" || error_exit "Fehler beim Starten des neuen Containers."

echo "Stoppe den alten Container..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose down webhook-server" || error_exit "Fehler beim Herunterfahren des alten Containers."

echo "Starte den neuen Container auf dem alten Port..."
ssh $REMOTE_HOST "cd $REMOTE_DIR && docker-compose down webhook-server-new && docker-compose up -d webhook-server-new --name webhook-server" || error_exit "Fehler beim Starten des neuen Containers auf dem alten Port."

echo "Redeployment abgeschlossen!"
