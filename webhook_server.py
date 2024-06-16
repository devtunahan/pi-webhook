from flask import Flask, request, jsonify, abort
import subprocess
import hmac
import hashlib
import logging

app = Flask(__name__)
SECRET_TOKEN = '3af396fdcf36b803b11d81895b5b1b218354baa2a51a0e2c60e5f0db13820992'  # Setze deinen geheimen Token hier ein

# Konfiguration für Logging
logging.basicConfig(level=logging.INFO)

def verify_signature(request):
    signature = request.headers.get('X-Hub-Signature-256')
    if not signature:
        abort(400, 'Signature missing')
    sha_name, signature = signature.split('=')
    if sha_name != 'sha256':
        abort(400, 'Invalid signature format')
    mac = hmac.new(SECRET_TOKEN.encode(), msg=request.data, digestmod=hashlib.sha256)
    if not hmac.compare_digest(mac.hexdigest(), signature):
        abort(400, 'Invalid signature')

# @app.route('/webhook', methods=['POST'])
# def webhook():
#     logging.info('Webhook received')
#     verify_signature(request)
#     data = request.json
#     repository = data['repository']['name']
#     branch = data['ref'].split('/')[-1]
#     if repository == 'pi-webhook' and branch == 'main':
#         logging.info(f'Triggering redeployment for repository {repository} on branch {branch}')
#         result = subprocess.run(['./redeploy.sh'], capture_output=True, text=True)
#         logging.info(result.stdout)
#         if result.stderr:
#             logging.error(result.stderr)
#     return jsonify({'status': 'success'}), 200

# @app.route('/webhook/timeloom', methods=['POST'])
# def webhook_projekt1():
#     verify_signature(request)
#     data = request.json
#     if data['ref'] == 'refs/heads/main':
#         print("Hier kann das deployment scripts für timeloom ausgeführt werden!")
#         # subprocess.run(['./deploy_projekt1.sh'])
#     return jsonify({'status': 'success'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)