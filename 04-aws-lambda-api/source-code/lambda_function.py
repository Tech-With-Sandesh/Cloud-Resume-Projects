import json
import boto3
import os
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'users-table')
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Serverless REST API handler for user management.
    Routes: GET /users, POST /users, GET /users/{id}, DELETE /users/{id}
    """
    logger.info("Event received: %s", json.dumps(event))

    http_method = event.get('httpMethod', '')
    path        = event.get('path', '')
    path_params = event.get('pathParameters') or {}

    try:
        if http_method == 'GET' and path == '/users':
            return get_all_users()

        elif http_method == 'POST' and path == '/users':
            body = json.loads(event.get('body', '{}'))
            return create_user(body)

        elif http_method == 'GET' and path_params.get('id'):
            return get_user(path_params['id'])

        elif http_method == 'DELETE' and path_params.get('id'):
            return delete_user(path_params['id'])

        else:
            return response(404, {'error': 'Route not found'})

    except Exception as e:
        logger.error("Unhandled error: %s", str(e))
        return response(500, {'error': 'Internal server error'})


def get_all_users():
    result = table.scan(Limit=100)
    return response(200, {'users': result.get('Items', [])})


def create_user(body):
    if not body.get('name') or not body.get('email'):
        return response(400, {'error': 'name and email are required'})

    user_id = str(int(datetime.utcnow().timestamp() * 1000))
    item = {
        'id':         user_id,
        'name':       body['name'],
        'email':      body['email'],
        'created_at': datetime.utcnow().isoformat()
    }
    table.put_item(Item=item)
    logger.info("Created user: %s", user_id)
    return response(201, {'message': 'User created', 'user': item})


def get_user(user_id):
    result = table.get_item(Key={'id': user_id})
    item = result.get('Item')
    if not item:
        return response(404, {'error': f'User {user_id} not found'})
    return response(200, {'user': item})


def delete_user(user_id):
    result = table.get_item(Key={'id': user_id})
    if not result.get('Item'):
        return response(404, {'error': f'User {user_id} not found'})
    table.delete_item(Key={'id': user_id})
    logger.info("Deleted user: %s", user_id)
    return response(200, {'message': f'User {user_id} deleted'})


def response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type':                'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body)
    }
