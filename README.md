# Cloud-Native E-Learning Platform on AWS

## At a glance

| | |
|---|---|
| **What** | A serverless e-learning platform: users sign up, solve generated maths exercises (addition, multiplication, derivatives) and see their results. Course project in Advanced Internet Computing, TU Wien. |
| **Highlights** | Infrastructure as Code with the AWS CDK.<br>Amazon Cognito for sign-up and login, API Gateway and Lambda, exercise generation via SNS and SQS, results computed with DynamoDB Streams, pictures in S3.<br>Runs fully locally on LocalStack with one `docker compose up`.<br>Measured deployment times and the serverless cold-start effect: first requests took up to about 4 s, repeat requests under 1 s. |
| **Stack** | Python (AWS Lambda, AWS CDK), Flutter, LocalStack, Docker |
| **Docs** | [Technical report (PDF)](report/AIC_Report_T2.pdf) |

### Getting started

1. Run in project root directory:

        docker compose up --build


2. Wait for deployment. The link for the s3 bucket of Flutter is: flutter-bucket.s3-website.eu-west-1.localhost.localstack.cloud

3. Register a user and login with the entered information.

4. Select an exercise type and enter an answer.

5. Results can be viewed in the results tab.
