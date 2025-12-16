import os
from aws_cdk import (
    aws_s3 as s3,
    CfnOutput,
    Stack,
    Duration,
)
from constructs import Construct
import aws_cdk.aws_s3_deployment as s3deploy
import aws_cdk.aws_cloudfront as cloudfront
import aws_cdk.aws_cloudfront_origins as origins


class S3Stack(Stack):
    """Create a Stack for a given task type to handle task creation notifications"""

    def __init__(self, scope: Construct, construct_id: str) -> None:
        super().__init__(scope, construct_id)

        self.bucket = s3.Bucket(self, "s3Bucket")

        self.bucket.add_lifecycle_rule(
            enabled=True,
        )

        CfnOutput(self, "s3BucketName", value=self.bucket.bucket_name)

        flutter_bucket = s3.Bucket(
            self,
            "FlutterBucket",
            bucket_name="flutter-bucket",
            public_read_access=True,
            website_index_document="index.html",
            website_error_document="index.html",
        )

        flutter_bucket.add_lifecycle_rule(
            enabled=True, abort_incomplete_multipart_upload_after=Duration.days(7)
        )

        if not os.path.isdir("/opt/g7t2/ui/build/web"):
            CfnOutput(self, "EmptyFlutterBucket:", value=flutter_bucket.bucket_name)
            return

        s3deploy.BucketDeployment(
            self,
            "DeployFlutterBucket",
            sources=[s3deploy.Source.asset("/opt/g7t2/ui/build/web")],
            destination_bucket=flutter_bucket,
        )

        distribution = cloudfront.Distribution(
            self,
            "flutter-distribution",
            default_behavior=cloudfront.BehaviorOptions(
                origin=origins.S3Origin(flutter_bucket)
            ),
        )

        CfnOutput(self, "FlutterBucketDomainName:", value=distribution.domain_name)
