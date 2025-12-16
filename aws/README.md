### Getting started

1. Add LOCALSTACK_API_KEY environment variable to your .env file

2. Install dependencies:

        make install

3. Localstack deploy:

        make localstack

4. Deploy:

        make deploy

5. Shutdown Localstack:

        make localstack-down



### Testing lambda functions:

1. Go to Localstack Webapp > Resources > Lambdas
2. Get lambda name of a handler
3. awslocal lambda invoke --payload file://message.json output.txt --function-name <NAME>

### Localstack Resource Explorer 

`https://app.localstack.cloud/instances`