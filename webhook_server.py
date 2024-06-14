from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/webhook', methods=['POST'])
def webhook():
    if request.method == 'POST':
        # Führe das Deployment Skript aus
        subprocess.call(['/app/deployment-script.sh'])
        return 'Success', 200
    else:
        return 'Invalid request', 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
