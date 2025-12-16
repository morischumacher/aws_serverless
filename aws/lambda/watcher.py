from __future__ import print_function

import json
import decimal
import boto3
from boto3.dynamodb.conditions import Key, Attr


class DecimalEncoder(json.JSONEncoder):
    """Helper class to convert a DynamoDB item to JSON"""

    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)


# Get the resources.
sns_client = boto3.client("sns")
dynamodb = boto3.resource("dynamodb")
sts_client = boto3.client("sts")
table_name = list(dynamodb.tables.all())[0].name
region = boto3.session.Session().region_name
account_id = sts_client.get_caller_identity()["Account"]


def handler(event, _):
    """Check if there are enough exercises of a type for a user"""
    table = dynamodb.Table(table_name)
    records = []
    for record in event["Records"]:
        if record["eventName"] != "INSERT":
            records.append(record)

    user_id = records[0]["dynamodb"]["Keys"]["user_id"]["S"]
    exercise_type = records[0]["dynamodb"]["NewImage"]["type"]["S"]
    response = table.query(
        KeyConditionExpression=Key("user_id").eq(user_id),
        FilterExpression=Attr("type").eq(exercise_type) & Attr("is_solved").eq(0),
    )
    num_items = len(response["Items"])
    print("Detecting items before: ", num_items)
    # if len(records) > 5:

    if num_items < 5:
        message = {"user_id": user_id, "number_of_exercises": 1}
        sns_client.publish(
            TopicArn=f"arn:aws:sns:{region}:{account_id}:sns_topic_" + exercise_type,
            Message=json.dumps({"default": json.dumps(message)}),
            MessageStructure="json",
            Subject="Generate new exercise of type " + exercise_type,
        )
    return {
        "statusCode": 200,
        "body": json.dumps("Watcher checked exercises", cls=DecimalEncoder),
    }
