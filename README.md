# FastAPI Lambda POC

## Content
- [About](#about)
- [Setup](#setup)
  - [Initialize Terraform](#initialize-terraform)
  - [Package Lambda Code](#package-lambda-code)
  - [Deploy](#deploy)
  - [Take Down](#take-down)
- [Testing the App](#testing-the-app)

## About
This is a small POC / template for deploying a FastAPI application to AWS lambda
and exposing it via API gateway. The app is quite simple and contains a single `GET`
endpoint, a single `POST` endpoint, and a documentation URL. The app's
infrastructure is deployed and managed using [terraform](https://www.terraform.io/).

## Setup
In order to set up the POC, first ensure you have the AWS credentials necessary for the deployment,
and that you have Python `3.9` installed in your working environment. You must also have a Linux OS
to run the packaging and deployment, since AWS lambda runs on AmazonLinux. The setup is handled using
[Task](https://taskfile.dev/) to handle tasks.

### Initialize Terraform
The first thing you should do before deploying is to initialize Terraform for the project's
infrastructure. To do this, you can run `task terraform init` if you have Task installed. If you don't,
go to the `infrastructure` directory and run `terraform init`.

### Package Lambda Code
Next, you must package the lambda function's code and library dependencies in a zip file that can
be uploaded to AWS. If you have `Task`, you can do this by running `task package-lambda`.

### Deploy
Finally, to deploy the infrastructure to AWS using terraform, you can run `task deploy`. If you are too
impatient to run the two steps above separately, you can run this command from the start, and it will
run the others as dependencies. Once terraform has deployed the app, it will output the docs URL to the
terminal. You can then go to this URL to play around with the endpoints.

### Take Down
Once you are done with the app, you can take it down from AWS by running `task take-down` to delete
the infrastructure.

## Testing the App
Once the app is deployed, you can test it by hitting the API endpoints or by consulting the docs URL.
The API endpoints require you to send an API Key under the `x-api-key` header. This key is generated by
AWS and is output by terraform after deploying (this is a sensitive output, so it won't show up in the
console). To view it, run `terraform output api_key` in the `infrastructure` directory.

Once you have fetched the key and the invoke URL from the terraform outputs, you can cunsult the endpoints
with:
```python
import requests

endpoint_url = "{invoke-url}"
api_key = "{api-key}"

# Get endpoint
rsp = requests.get(
    "%s/dev/api/v1/add-numbers" % endpoint_url,
    params={"a": 1, "b": 2},
    headers={"x-api-key": api_key}
)
print(rsp, rsp.json())

# Post endpoint
rsp = requests.post(
    "%s/dev/api/v1/add-numbers" % endpoint_url,
    json={"a": 1, "b": 2},
    headers={"x-api-key": api_key}
)

print(rsp, rsp.json())
```

[Back to top.](#fastapi-lambda-poc)
