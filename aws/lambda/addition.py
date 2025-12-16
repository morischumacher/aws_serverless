import random
import json
import boto3


# Get the service resource.
dynamodb = boto3.resource("dynamodb")
tables = list(dynamodb.tables.all())[0].name


def handler(event, _):
    """Read clientId from SQS and generate addition for user"""
    table = dynamodb.Table(tables)
    additions = []

    try:
        print("Event: ", event)
        input_dict = json.loads(event["Records"][0]["body"])
        print("Input: ", input_dict)

        for _ in range(0, input_dict["number_of_exercises"]):
            exercise = _generate_addition()
            response = table.put_item(
                Item={
                    "type": "addition",
                    "exercise": str(exercise),
                    "user_id": input_dict["user_id"],
                    "is_solved": 0,
                    "params": str(
                        {
                            "solution": "",
                            "score": "",
                            "correct_solution": "",
                        }
                    ),
                }
            )
            item = response
            print(item)
            additions.append(exercise)

        return_object = {"statusCode": 200, "body": additions}
        print(return_object)
        return return_object
    except (ValueError, TypeError, KeyError) as _:
        return_object = {"statusCode": 400, "body": "Invalid input"}
        print(return_object)
        return return_object


def _generate_addition():
    number_of_values = random.randint(2, 3)
    values = []

    for _ in range(0, number_of_values):
        values.append(random.randint(0, 100))

    # return the result
    return values
