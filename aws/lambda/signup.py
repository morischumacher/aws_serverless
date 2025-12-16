import os
import json
import boto3

sns_client = boto3.client("sns")
sts_client = boto3.client("sts")
region = boto3.session.Session().region_name
account_id = sts_client.get_caller_identity()["Account"]


def handler(event, _):
    """Add a new user to the user pool and publish a message to the
    SNS topic for each exercise type"""
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
        response = client.sign_up(
            ClientId=user_pool_client_id,
            Username=body["email"],
            Password=body["password"],
            UserAttributes=[
                {
                    "Name": "email",
                    "Value": body["email"],
                },
                {
                    "Name": "name",
                    "Value": body["name"],
                },
            ],
        )

        _publish_to_sns("addition", response["UserSub"])
        _publish_to_sns("derivative", response["UserSub"])
        _publish_to_sns("multiplication", response["UserSub"])

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
                "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
                "Content-Type": "application/json",
            },
            "body": json.dumps(response),
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps(str(e)),
        }


def _publish_to_sns(exercise_type, user_id):
    message = {"user_id": user_id, "number_of_exercises": 10}
    sns_client.publish(
        TopicArn=f"arn:aws:sns:{region}:{account_id}:sns_topic_" + exercise_type,
        Message=json.dumps({"default": json.dumps(message)}),
        MessageStructure="json",
        Subject="Generate new exercise of type " + exercise_type,
    )
