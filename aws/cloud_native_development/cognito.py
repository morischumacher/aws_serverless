from aws_cdk import (
    Stack,
    CfnOutput,
    aws_cognito as cognito,
    aws_lambda as _lambda,
    Duration,
)
from constructs import Construct
import aws_cdk as cdk


class CognitoStack(Stack):
    """Create a Stack for Cognito"""

    def __init__(self, scope: Construct, id: str, **kwargs) -> None:
        super().__init__(scope, id)

        lambda_dir = kwargs["lambda_dir"]
        lambda_timeout = kwargs["lambda_timeout"]

        pre_signup_trigger = _lambda.Function(
            self,
            "PreSignUpTrigger",
            code=_lambda.Code.from_asset(path=lambda_dir),
            handler="pre_signup_trigger.handler",
            runtime=_lambda.Runtime.PYTHON_3_9,
            timeout=Duration.seconds(lambda_timeout),
        )

        self.user_pool = cognito.UserPool(
            self,
            "CognitoStackUserPool",
            self_sign_up_enabled=True,
            sign_in_aliases=cognito.SignInAliases(email=True),
            standard_attributes=cognito.StandardAttributes(
                email=cognito.StandardAttribute(required=True),
                fullname=cognito.StandardAttribute(required=True),
            ),
            auto_verify=cognito.AutoVerifiedAttrs(email=True),
            password_policy=cognito.PasswordPolicy(
                min_length=8,
                require_lowercase=False,
                require_digits=False,
                require_symbols=False,
                require_uppercase=False,
            ),
            account_recovery=cognito.AccountRecovery.NONE,
            removal_policy=cdk.RemovalPolicy.DESTROY,
            lambda_triggers=cognito.UserPoolTriggers(
                pre_sign_up=pre_signup_trigger,
            ),
        )

        self.user_pool_client = self.user_pool.add_client(
            "CognitoStackUserPoolClient",
            generate_secret=True,
            auth_flows=cognito.AuthFlow(
                user_password=True,
                # user_srp=True,
                # refresh_token=True,
            ),
            prevent_user_existence_errors=True,
            # read_attributes=cognito.ClientAttributes().with_standard_attributes(
            #    fullname=True
            # ),
            # write_attributes=cognito.ClientAttributes().with_standard_attributes(
            #    fullname=True
            # ),
        )

        CfnOutput(self, "UserPoolId", value=self.user_pool.user_pool_id)
        CfnOutput(
            self, "UserPoolClientId", value=self.user_pool_client.user_pool_client_id
        )
