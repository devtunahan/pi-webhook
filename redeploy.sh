#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to handle errors
error_exit()
{
    echo "$1" 1>&2
    exit 1
}

echo "Beende den Container..."
ssh pi@192.168.68.114 "docker-compose down" || error_exit "Fehler beim Beenden des Containers."

echo "Baue das Docker-Image neu..."
ssh pi@192.168.68.114 "docker-compose build" || error_exit "Fehler beim Bauen des Docker-Images."

echo "Starte den Container erneut..."
ssh pi@192.168.68.114 "docker-compose up -d" || error_exit "Fehler beim Starten des Containers."

echo "Redeployment abgeschlossen."
