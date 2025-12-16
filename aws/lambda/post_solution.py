import json
import boto3

client = boto3.client("sns")
sts_client = boto3.client("sts")
region = boto3.session.Session().region_name
account_id = sts_client.get_caller_identity()["Account"]


def handler(event, _):
    """Route the incoming request based on type (addition, multiplication, derivative)
    to the corresponding SNS topic for post solution"""
    try:
        user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
        message = json.loads(event["body"])
        exercise_type = message["type"]
        print(message)
        params_str = message["params"].replace("'", '"')

        send_message = {
            "user_id": user_id,
            "exercise": message["exercise"],
            "type": exercise_type,
            "params": params_str,
        }
        json_message = json.dumps(send_message)
        response = client.publish(
            TopicArn=f"arn:aws:sns:{region}:{account_id}:sns_topic_{exercise_type}_post_solution",
            Message=str(json_message),
        )
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
                "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": response,
        }
    except Exception as e:
        print(e)
        return_object = {
            "statusCode": 400,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
                "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "body": e,
        }
        return return_object
