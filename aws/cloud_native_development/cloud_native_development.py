from constructs import Construct

from cloud_native_development.s3 import S3Stack
from cloud_native_development.sns_sqs_lambda import SnsSqsLambdaStack
from cloud_native_development.post_solution import PostSolutionStack

from cloud_native_development.dynamodb import DynamodbStack
from cloud_native_development.cognito import CognitoStack
from cloud_native_development.gateway import GatewayStack


class CloudNativeDevelopmentService(Construct):
    """Class to handle the creation of all necessary stacks
    for the Cloud Native Development Service"""

    def __init__(self, scope: Construct, id: str) -> None:
        super().__init__(scope, id)

        lambda_dir = "lambda"
        lambda_timeout = 30

        SnsSqsLambdaStack(
            self,
            "addition_creation_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="addition",
        )
        SnsSqsLambdaStack(
            self,
            "multiplication_creation_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="multiplication",
        )
        SnsSqsLambdaStack(
            self,
            "derivative_creation_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="derivative",
        )

        PostSolutionStack(
            self,
            "post_solution_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
        )
        DynamodbStack(
            self,
            "dynamodb_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="get_exercises",
        )

        s3bucket = S3Stack(
            self,
            "s3_stack",
        )

        cognito_stack = CognitoStack(
            self,
            "cognito_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
        )

        GatewayStack(
            self,
            "gateway_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            user_pool=cognito_stack.user_pool,
            user_pool_client=cognito_stack.user_pool_client,
            s3_bucket_name=s3bucket.bucket.bucket_name,
        )
