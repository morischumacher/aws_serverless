#!/usr/bin/env python3
import aws_cdk as cdk

from cloud_native_development.cloud_native_development import (
    CloudNativeDevelopmentService,
)

app = cdk.App()
CloudNativeDevelopmentService(app, "cloud-native-development-service")

app.synth()
