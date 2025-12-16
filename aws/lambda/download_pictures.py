from urllib.parse import unquote_plus
import base64
import os
import json
import boto3


def handler(event, _):
    """Handles the download of a picture from S3"""
    client = boto3.client("s3")
    filename = event["requestContext"]["authorizer"]["claims"]["sub"]

    # Unquote and decode the filename
    object_key = unquote_plus(filename)

    try:
        response = client.get_object(
            Bucket=os.environ["S3_BUCKET_NAME"], Key=object_key
        )

        image_data = response["Body"].read()

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "image/jpeg",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Credentials": True,
                "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
                "Access-Control-Allow-Methods": "GET, OPTIONS",
            },
            "body": base64.b64encode(image_data).decode("utf-8"),
            "isBase64Encoded": False,
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)}),
            "isBase64Encoded": False,
        }
