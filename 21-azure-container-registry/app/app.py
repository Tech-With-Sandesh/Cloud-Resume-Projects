from flask import Flask, jsonify
import os, socket

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'acr-demo', 'hostname': socket.gethostname()}), 200

@app.route('/')
def index():
    return jsonify({'message': 'Hello from Azure Container Registry!', 'version': os.environ.get('APP_VERSION', '1.0.0')}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
