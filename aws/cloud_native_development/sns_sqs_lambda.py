from aws_cdk import (
    Stack,
    Duration,
    aws_lambda as _lambda,
    aws_lambda_event_sources as lambda_events,
    aws_sns as sns,
    aws_sns_subscriptions as sns_subs,
    aws_sqs as sqs,
)
from constructs import Construct


class SnsSqsLambdaStack(Stack):
    """Create a Stack for a given task type to handle task creation notifications"""

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id)

        lambda_dir = kwargs["lambda_dir"]
        lambda_timeout = kwargs["lambda_timeout"]
        name = "_" + kwargs["name"]

        dlq = sqs.Queue(
            self, id="dead_letter_queue" + name, retention_period=Duration.days(7)
        )
        dead_letter_queue = sqs.DeadLetterQueue(max_receive_count=1, queue=dlq)

        upload_queue = sqs.Queue(
            self,
            id="queue" + name,
            dead_letter_queue=dead_letter_queue,
            visibility_timeout=Duration.seconds(lambda_timeout * 6),
        )

        sqs_subscription = sns_subs.SqsSubscription(
            upload_queue, raw_message_delivery=True
        )

        event_topic = sns.Topic(
            self,
            id="sns_topic" + name,
            display_name="sns_topic" + name,
            topic_name="sns_topic" + name,
        )

        # This binds the SNS Topic to the SQS Queue
        event_topic.add_subscription(sqs_subscription)

        function = _lambda.Function(
            self,
            kwargs["name"],
            runtime=_lambda.Runtime.PYTHON_3_9,
            handler=kwargs["name"] + ".handler",
            code=_lambda.Code.from_asset(path=lambda_dir),
            timeout=Duration.seconds(lambda_timeout),
        )

        invoke_event_source = lambda_events.SqsEventSource(upload_queue)
        function.add_event_source(invoke_event_source)
