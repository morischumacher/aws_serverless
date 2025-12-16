import json
import decimal
import boto3
from boto3.dynamodb.conditions import Key


class DecimalEncoder(json.JSONEncoder):
    """Helper class to convert a DynamoDB item to JSON"""

    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)


dynamodb = boto3.resource("dynamodb")
table_name = list(dynamodb.tables.all())[0].name


def handler(event, _):
    """Get all exercises and grades for a user"""
    user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
    print("User ID is: ", user_id)

    table = dynamodb.Table(table_name)

    # Scan the table
    response = table.query(KeyConditionExpression=Key("user_id").eq(user_id))

    return_obj = {
        "addition": {"ratio": 0, "grade": 0, "exercises": []},
        "multiplication": {"ratio": 0, "grade": 0, "exercises": []},
        "derivative": {"ratio": 0, "grade": 0, "exercises": []},
    }

    solved_exercises = [0, 0, 0]
    score_exercises = [0, 0, 0]

    # Process the items
    for item in response["Items"]:
        print(item)
        exercise_type = item["type"]
        is_solved = item["is_solved"]

        params_str = item["params"].replace("'", '"')
        params = json.loads(params_str)
        scored = params["score"]

        if exercise_type == "addition":
            return_obj["addition"]["exercises"].append(item)
            if is_solved == 1:
                solved_exercises[0] += 1
            if scored == 1:
                score_exercises[0] += 1
        elif exercise_type == "multiplication":
            return_obj["multiplication"]["exercises"].append(item)
            if is_solved == 1:
                solved_exercises[1] += 1
            if scored == 1:
                score_exercises[1] += 1
        elif exercise_type == "derivative":
            return_obj["derivative"]["exercises"].append(item)
            if is_solved == 1:
                solved_exercises[2] += 1
            if scored == 1:
                score_exercises[2] += 1

    try:
        return_obj["addition"]["ratio"] = score_exercises[0] / solved_exercises[0]
    except:
        return_obj["addition"]["ratio"] = 0

    try:
        return_obj["multiplication"]["ratio"] = score_exercises[1] / solved_exercises[1]
    except:
        return_obj["multiplication"]["ratio"] = 0

    try:
        return_obj["derivative"]["ratio"] = score_exercises[2] / solved_exercises[2]
    except:
        return_obj["derivative"]["ratio"] = 0

    if return_obj["addition"]["ratio"] > 0.87:
        return_obj["addition"]["grade"] = 1

    elif (
        return_obj["addition"]["ratio"] <= 0.87
        and return_obj["addition"]["ratio"] > 0.74
    ):
        return_obj["addition"]["grade"] = 2

    elif (
        return_obj["addition"]["ratio"] <= 0.74
        and return_obj["addition"]["ratio"] > 0.59
    ):
        return_obj["addition"]["grade"] = 3

    elif (
        return_obj["addition"]["ratio"] <= 0.59
        and return_obj["addition"]["ratio"] > 0.49
    ):
        return_obj["addition"]["grade"] = 4

    else:
        return_obj["addition"]["grade"] = 5

    if return_obj["multiplication"]["ratio"] > 0.87:
        return_obj["multiplication"]["grade"] = 1

    elif (
        return_obj["multiplication"]["ratio"] <= 0.87
        and return_obj["multiplication"]["ratio"] > 0.74
    ):
        return_obj["multiplication"]["grade"] = 2

    elif (
        return_obj["multiplication"]["ratio"] <= 0.74
        and return_obj["multiplication"]["ratio"] > 0.59
    ):
        return_obj["multiplication"]["grade"] = 3

    elif (
        return_obj["multiplication"]["ratio"] <= 0.59
        and return_obj["multiplication"]["ratio"] > 0.49
    ):
        return_obj["multiplication"]["grade"] = 4

    else:
        return_obj["multiplication"]["grade"] = 5

    if return_obj["derivative"]["ratio"] > 0.87:
        return_obj["derivative"]["grade"] = 1

    elif (
        return_obj["derivative"]["ratio"] <= 0.87
        and return_obj["derivative"]["ratio"] > 0.74
    ):
        return_obj["derivative"]["grade"] = 2

    elif (
        return_obj["derivative"]["ratio"] <= 0.74
        and return_obj["derivative"]["ratio"] > 0.59
    ):
        return_obj["derivative"]["grade"] = 3

    elif (
        return_obj["derivative"]["ratio"] <= 0.59
        and return_obj["derivative"]["ratio"] > 0.49
    ):
        return_obj["derivative"]["grade"] = 4

    else:
        return_obj["derivative"]["grade"] = 5

    print(json.dumps(return_obj, indent=4, cls=DecimalEncoder))

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": True,
            "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
            "Access-Control-Allow-Methods": "GET, OPTIONS",
        },
        "body": json.dumps(return_obj, cls=DecimalEncoder),
    }
