from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'ecs-fargate-app'}), 200

@app.route('/ready')
def ready():
    return jsonify({'status': 'ready'}), 200

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from ECS Fargate!',
        'hostname': socket.gethostname(),
        'environment': os.environ.get('APP_ENV', 'production')
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
