FROM python:3.9-slim

# Installiere den SSH-Client
RUN apt-get update && apt-get install -y openssh-client

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

# Stelle sicher, dass redeploy.sh ausführbar ist
RUN chmod +x redeploy.sh

CMD ["python", "webhook_server.py"]
