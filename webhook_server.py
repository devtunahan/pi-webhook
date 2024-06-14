from flask import Flask, request, abort
import subprocess
import hmac
import hashlib
import logging

app = Flask(__name__)

# Logging konfigurieren
logging.basicConfig(filename='/var/log/webhook.log', level=logging.INFO)

@app.route('/webhook', methods=['POST'])
def webhook():
    if request.method == 'POST':        
        data = request.get_json()
        if not data:
            logging.error('Invalid payload')
            abort(400)

        # Überprüfen, ob es sich um ein Push-Event auf den Main Branch handelt
        if data.get('ref') == 'refs/heads/main':
            try:
                # Führe das Deployment Skript aus
                result = subprocess.run(['/app/deployment-script.sh'], capture_output=True, text=True)
                if result.returncode == 0:
                    logging.info('Deployment script executed successfully')
                    logging.info(result.stdout)
                    return 'Success', 200
                else:
                    logging.error('Deployment script failed')
                    logging.error(result.stderr)
                    return 'Script execution failed', 500
            except Exception as e:
                logging.error(f'Error executing script: {e}')
                return 'Error', 500
        else:
            return 'No action for this branch', 200
    else:
        return 'Invalid request', 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
