from __future__ import print_function

import json
import decimal
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


# Get the service resource.
dynamodb = boto3.resource("dynamodb")
table_name = list(dynamodb.tables.all())[0].name


def handler(event, _):
    """Post solution to derivative exercise and grade it"""
    try:
        table = dynamodb.Table(table_name)

        body = event["Records"][0]["body"]
        print(body)
        body = json.loads(body)
        exercise_str = body["exercise"].replace("'", '"')
        exercise = json.loads(exercise_str)
        params_str = body["params"].replace("'", '"')
        params = json.loads(params_str)
        print("json", body)
        print("exercise", body["exercise"])
        print("user_id", body["user_id"])

        result = derivative(exercise)

        if json.dumps(
            sort_by_degree(params["solution"]), indent=4, cls=DecimalEncoder
        ) == json.dumps(result, indent=4, cls=DecimalEncoder):
            score = 1
        else:
            score = 0

        response = table.update_item(
            Key={"exercise": body["exercise"], "user_id": body["user_id"]},
            AttributeUpdates={
                "is_solved": {"Value": 1, "Action": "PUT"},
                "params": {
                    "Value": str(
                        {
                            "solution": params["solution"],
                            "score": score,
                            "correct_solution": result,
                        }
                    ),
                    "Action": "PUT",
                },
            },
            ReturnValues="UPDATED_NEW",
        )
        print(response)
        print(json.dumps(response, indent=4, cls=DecimalEncoder))

        return {"statusCode": 200, "body": json.dumps(response, cls=DecimalEncoder)}
    except Exception as e:
        print("DIDNT WORK", e)
        return {"statusCode": 500, "body": json.dumps(str(e))}


def derivative(exercise):
    """Calculate the derivative of a polynomial"""
    values = exercise["values"]
    degrees = exercise["degrees"]

    new_values = []
    new_degrees = []

    for i, i_value in enumerate(values):
        for j in range(i + 1, len(values)):
            if degrees[i] == degrees[j]:
                i_value += values[j]
                values[j] = 0

    for i, i_value in enumerate(values):
        if degrees[i] == 0 or i_value == 0:
            continue

        new_values.append(values[i] * degrees[i])
        new_degrees.append(degrees[i] - 1)

    if len(new_values) == 0:
        return {"values": [0], "degrees": [0]}

    return sort_by_degree({"values": new_values, "degrees": new_degrees})


def sort_by_degree(exercise):
    """Sort polynomial by degree"""
    values = exercise["values"]
    degrees = exercise["degrees"]

    for i, i_degree in enumerate(degrees):
        for j in range(i + 1, len(degrees)):
            if i_degree > degrees[j]:
                i_degree, degrees[j] = degrees[j], i_degree
                values[i], values[j] = values[j], values[i]
    return {"values": values, "degrees": degrees}
