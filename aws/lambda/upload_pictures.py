import base64
import os
import json
import boto3


def handler(event, _):
    """Handle upload of pictures to S3"""
    client = boto3.client("s3")

    try:
        body = json.loads(event["body"])
        filename = event["requestContext"]["authorizer"]["claims"]["sub"]
        content_type = body.get("content_type")
        base64_data = body.get("base64_data")

        if not (filename and content_type and base64_data):
            raise ValueError(
                """Incomplete request. Make sure 'filename', 'content_type',
                    and 'base64_data' are provided in the request body."""
            )

        decoded_data = base64.b64decode(base64_data)

        client.put_object(
            Bucket=os.environ["S3_BUCKET_NAME"],
            Key=filename,
            Body=decoded_data,
            ContentType=content_type,
        )

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Upload successful"}),
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
                "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                "Access-Control-Allow-Methods": "POST, OPTIONS",
            },
            "isBase64Encoded": False,
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
            "isBase64Encoded": False,
        }
