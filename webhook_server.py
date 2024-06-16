from flask import Flask, request, jsonify, abort
import subprocess
import hmac
import hashlib
import logging
import os

app = Flask(__name__)
SECRET_TOKEN = os.getenv('SECRET_TOKEN', '3af396fdcf36b803b11d81895b5b1b218354baa2a51a0e2c60e5f0db13820992')

# Konfiguration für Logging
logging.basicConfig(level=logging.INFO)

def verify_signature(request):
    signature = request.headers.get('X-Hub-Signature-256')
    if not signature:
        logging.error('Signature missing')
        abort(400, 'Signature missing')
    sha_name, signature = signature.split('=')
    if sha_name != 'sha256':
        logging.error('Invalid signature format')
        abort(400, 'Invalid signature format')
    mac = hmac.new(SECRET_TOKEN.encode(), msg=request.data, digestmod=hashlib.sha256)
    if not hmac.compare_digest(mac.hexdigest(), signature):
        logging.error('Invalid signature')
        abort(400, 'Invalid signature')

@app.route('/webhook/timeloom', methods=['POST'])
def webhook_timeloom():
    logging.info('Webhook received for timeloom')
    try:
        verify_signature(request)
    except Exception as e:
        logging.error(f'Error verifying signature: {e}')
        return jsonify({'status': 'error', 'message': str(e)}), 400
    
    data = request.json
    repository = data['repository']['name']
    branch = data['ref'].split('/')[-1]
    if repository == 'timeloom' and branch == 'main':
        logging.info(f'Triggering redeployment for repository {repository} on branch {branch}')
        try:
            result = subprocess.run(['./redeploy.sh'], capture_output=True, text=True)
            logging.info(result.stdout)
            if result.stderr:
                logging.error(result.stderr)
                return jsonify({'status': 'error', 'message': result.stderr}), 500
        except Exception as e:
            logging.error(f'Error executing redeploy.sh: {e}')
            return jsonify({'status': 'error', 'message': str(e)}), 500
    return jsonify({'status': 'success'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
