from aws_cdk import Stack, Duration, Tags

from aws_cdk.aws_apigateway import (
    RestApi,
    LambdaIntegration,
    CognitoUserPoolsAuthorizer,
    AuthorizationType,
)
from aws_cdk.aws_lambda import Function, Code, Runtime
from aws_cdk.aws_cognito import UserPool, UserPoolClient

from constructs import Construct


class GatewayStack(Stack):
    """Create a Stack for the API Gateway"""

    def __init__(self, scope: Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id)

        lambda_dir = kwargs["lambda_dir"]
        lambda_timeout = kwargs["lambda_timeout"]
        user_pool_client: UserPoolClient = kwargs["user_pool_client"]
        bucket_name = kwargs["s3_bucket_name"]
        user_pool: UserPool = kwargs["user_pool"]

        user_pool_client_id = (
            str(user_pool_client.user_pool_client_id)
            .rsplit("/", maxsplit=1)[-1]
            .rsplit("-", maxsplit=1)[-1]
        )

        # Create the API Gateway
        api = RestApi(
            self,
            "Gateway",
            rest_api_name="Gateway",
            default_cors_preflight_options={
                "allow_origins": ["*"],
                "allow_methods": ["GET", "POST", "OPTIONS"],
                "allow_headers": [
                    "Origin",
                    "Content-Type",
                    "X-Amz-Date",
                    "Authorization",
                    "X-Api-Key",
                    "X-Amz-Security-Token",
                    "locale",
                ],
                "allow_credentials": True,
            },
        )

        # Make the URL of the API Gateway static
        Tags.of(api).add("_custom_id_", "gateway")

        authorizer = CognitoUserPoolsAuthorizer(
            self,
            "CognitoAuthorizer",
            cognito_user_pools=[user_pool],
            authorizer_name="CognitoAuthorizer",
            identity_source="method.request.header.Authorization",
        )

        # Create the 'signup' lambda
        signup_lambda = Function(
            self,
            "SignupLambda",
            code=Code.from_asset(path=lambda_dir),
            handler="signup.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
            environment={
                "USER_POOL_CLIENT_ID": user_pool_client_id,
            },
        )

        # Create the 'signin' lambda
        signin_lambda = Function(
            self,
            "SigninLambda",
            code=Code.from_asset(path=lambda_dir),
            handler="signin.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
            environment={
                "USER_POOL_CLIENT_ID": user_pool_client_id,
            },
        )

        # Create the 'upload_pp' lambda
        upload_pp_lambda = Function(
            self,
            "Upload_PP_Lambda",
            code=Code.from_asset(path=lambda_dir),
            handler="upload_pictures.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
            environment={
                "S3_BUCKET_NAME": bucket_name,
            },
        )

        # Create the 'download_pp' lambda
        download_pp_lambda = Function(
            self,
            "Download_PP_Lambda",
            code=Code.from_asset(path=lambda_dir),
            handler="download_pictures.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
            environment={
                "S3_BUCKET_NAME": bucket_name,
            },
        )
        get_exercise_lambda = Function(
            self,
            "Get_Exercise_Lambda",
            code=Code.from_asset(path=lambda_dir),
            handler="get_exercise.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
        )

        post_solution_lambda = Function(
            self,
            "post_solution",
            code=Code.from_asset(path=lambda_dir),
            handler="post_solution.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
        )

        get_profile_lambda = Function(
            self,
            "get_profile",
            code=Code.from_asset(path=lambda_dir),
            handler="get_profile.handler",
            runtime=Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
        )

        # Create the 'signup' route
        signup = api.root.add_resource("signup")
        signup.add_method("POST", LambdaIntegration(signup_lambda))

        # Create the 'signin' route
        signin = api.root.add_resource("signin")
        signin.add_method("POST", LambdaIntegration(signin_lambda))

        # Create the 'upload_pp' route
        post_pp = api.root.add_resource("post_pp")
        post_pp.add_method(
            "POST",
            LambdaIntegration(upload_pp_lambda),
            authorizer=authorizer,
            authorization_type=AuthorizationType.COGNITO,
        )

        # Create the 'download_pp' route
        get_pp = api.root.add_resource("get_pp")
        get_pp.add_method(
            "GET",
            LambdaIntegration(download_pp_lambda),
            authorizer=authorizer,
            authorization_type=AuthorizationType.COGNITO,
        )

        # Create the 'get_exercise' route
        get_exercise = api.root.add_resource("get_exercise")
        get_exercise.add_method(
            "GET",
            LambdaIntegration(get_exercise_lambda),
            authorizer=authorizer,
            authorization_type=AuthorizationType.COGNITO,
        )

        # Create the 'post_solution' route
        post_solution = api.root.add_resource("post_solution")
        post_solution.add_method(
            "POST",
            LambdaIntegration(post_solution_lambda),
            authorizer=authorizer,
            authorization_type=AuthorizationType.COGNITO,
        )

        get_profile_route = api.root.add_resource("get_profile")
        get_profile_route.add_method(
            "GET",
            LambdaIntegration(get_profile_lambda),
            authorizer=authorizer,
            authorization_type=AuthorizationType.COGNITO,
        )
