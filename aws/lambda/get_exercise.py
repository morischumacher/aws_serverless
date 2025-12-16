from __future__ import print_function
import json
import decimal
from boto3.dynamodb.conditions import Key

import boto3


class DecimalEncoder(json.JSONEncoder):
    """Helper class to convert a DynamoDB item to JSON"""

    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)


# Get first and only table


# Get the service resource.
dynamodb = boto3.resource("dynamodb")
table_name = list(dynamodb.tables.all())[0].name


def handler(event, _):
    """Get all unsolved exercises for a user"""
    user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
    print("User ID is: ", user_id)

    table = dynamodb.Table(table_name)

    # Initialize the lists
    exercises = {"addition": None, "multiplication": None, "derivative": None}

    # Scan the table
    response = table.query(KeyConditionExpression=Key("user_id").eq(user_id))

    # Process the items
    for item in response["Items"]:
        exercise_type = item["type"]
        is_solved = item["is_solved"]
        if (
            exercise_type in exercises
            and is_solved == 0
            and exercises[exercise_type] is None
        ):
            exercises[exercise_type] = item

    print(json.dumps(exercises, indent=4, cls=DecimalEncoder))

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": True,
            "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "GET, OPTIONS",
        },
        "body": json.dumps(exercises, cls=DecimalEncoder),
    }
