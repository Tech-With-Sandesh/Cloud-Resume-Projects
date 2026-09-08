from flask import Flask, jsonify, request
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'cloud-run-app'}), 200

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from GCP Cloud Run!',
        'project': os.environ.get('GOOGLE_CLOUD_PROJECT', 'unknown'),
        'region':  os.environ.get('CLOUD_RUN_REGION', 'unknown')
    }), 200

@app.route('/echo', methods=['POST'])
def echo():
    data = request.get_json(silent=True) or {}
    logger.info("Echo request: %s", data)
    return jsonify({'echo': data}), 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
