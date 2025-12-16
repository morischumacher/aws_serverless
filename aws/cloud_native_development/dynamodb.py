from aws_cdk import (
    aws_lambda,
    aws_dynamodb,
    Duration,
    Stack,
)
from aws_cdk.aws_dynamodb import StreamViewType
from aws_cdk.aws_lambda_event_sources import DynamoEventSource
from constructs import Construct


class DynamodbStack(Stack):
    """Create a Stack for dynamodb"""

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id)

        lambda_dir = kwargs["lambda_dir"]
        lambda_timeout = kwargs["lambda_timeout"]
        # create dynamo table
        exercises_table = aws_dynamodb.Table(
            self,
            "exercises",
            partition_key=aws_dynamodb.Attribute(
                name="user_id", type=aws_dynamodb.AttributeType.STRING
            ),
            sort_key=aws_dynamodb.Attribute(
                name="exercise", type=aws_dynamodb.AttributeType.STRING
            ),
            stream=StreamViewType.NEW_IMAGE,
        )

        exercises_table.add_global_secondary_index(
            index_name="exercise_type",
            partition_key=aws_dynamodb.Attribute(
                name="type", type=aws_dynamodb.AttributeType.STRING
            ),
        )
        exercises_table.add_global_secondary_index(
            index_name="exercise_solved",
            partition_key=aws_dynamodb.Attribute(
                name="is_solved", type=aws_dynamodb.AttributeType.NUMBER
            ),
        )
        exercises_table.add_global_secondary_index(
            index_name="params",
            partition_key=aws_dynamodb.Attribute(
                name="params", type=aws_dynamodb.AttributeType.STRING
            ),
        )

        watcher_lambda = aws_lambda.Function(
            self,
            "watcherLambda",
            runtime=aws_lambda.Runtime.PYTHON_3_8,
            handler="watcher.handler",
            code=aws_lambda.Code.from_asset(path=lambda_dir),
            timeout=Duration.seconds(lambda_timeout),
        )

        watcher_lambda.add_event_source(
            DynamoEventSource(
                exercises_table,
                starting_position=aws_lambda.StartingPosition.LATEST,
            )
        )
