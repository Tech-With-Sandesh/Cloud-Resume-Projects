from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'version': os.environ.get('APP_VERSION', '1.0.0')}), 200

@app.route('/')
def index():
    return jsonify({'message': 'Hello from Cloud Build CI/CD!', 'version': os.environ.get('APP_VERSION', '1.0.0')}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
