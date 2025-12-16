import os
import json
import boto3


def handler(event, _):
    """Handle sign in and return bearer token"""
    # receive cognito user pool client id from environment variables
    user_pool_client_id_old = os.environ["USER_POOL_CLIENT_ID"]

    user_pool_client_id = (
        str(user_pool_client_id_old)
        .rsplit("/", maxsplit=1)[-1]
        .rsplit("-", maxsplit=1)[-1]
    )

    client = boto3.client("cognito-idp")
    body = json.loads(event["body"])

    try:
        response = client.initiate_auth(
            ClientId=user_pool_client_id,
            AuthFlow="USER_PASSWORD_AUTH",
            AuthParameters={
                "USERNAME": body["email"],
                "PASSWORD": body["password"],
            },
        )
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
                "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": json.dumps(response),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(str(e)),
        }
