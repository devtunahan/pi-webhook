FROM python:3.9-slim

# Installiere den SSH-Client
RUN apt-get update && apt-get install -y openssh-client

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "webhook_server.py"]
