from aws_cdk import Stack
from constructs import Construct
from cloud_native_development.sns_sqs_lambda import SnsSqsLambdaStack


class PostSolutionStack(Stack):
    """Create a Stack for handeling solution post requests"""

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id)

        lambda_dir = kwargs["lambda_dir"]
        lambda_timeout = kwargs["lambda_timeout"]

        SnsSqsLambdaStack(
            self,
            "addition_post_solution_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="addition_post_solution",
        )
        SnsSqsLambdaStack(
            self,
            "multiplication_post_solution_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="multiplication_post_solution",
        )
        SnsSqsLambdaStack(
            self,
            "derivative_post_solution_stack",
            lambda_dir=lambda_dir,
            lambda_timeout=lambda_timeout,
            name="derivative_post_solution",
        )
