# Cloudformation

* A Template is equivalent to a .tf file - i.e. describing the resources to be provisioned
* A Stack provisions the resources described in a template

## Install hook

To install the hook provided in this repository, cd into the `hooks` directory and run:

```shell
cfn submit --set-default
```

When the command above is finished (may take several minutes), copy the value of `TypeArn`
from the response and store it in an environment variable:

```shell
export HOOK_TYPE_ARN="arn:aws:cloudformation:eu-north-1:677200501247:type/hook/Styra-OPA-Hook"
```


```shell
export AWS_REGION="eu-north-1"
export OPA_URL="http://206d-46-182-202-220.ngrok.io/v1/data/policy/deny"
```

```shell
aws cloudformation --region "$AWS_REGION" set-type-configuration \
  --configuration "{\"CloudFormationConfiguration\":{\"HookConfiguration\":{\"TargetStacks\":\"ALL\",\"FailureMode\":\"FAIL\",\"Properties\":{\"OpaUrl\": \"$OPA_URL\"}}}}" \
  --type-arn $HOOK_TYPE_ARN
```

```shell
aws cloudformation delete-stack --stack-name my-s3-stack
aws cloudformation create-stack --stack-name cfn-s3 --template-body file://templates/s3.yaml
aws cloudformation describe-stack-events --stack-name cfn-s3

# After changes
aws cloudformation update-stack --stack-name demo-s3 --template-body file://s3.yaml
```

See docs on registering the hook here:
https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/registering-hook-python.html


Test the hook by deploying a new S3 bucket (i.e. stack):
```shell
aws cloudformation create-stack \
  --stack-name my-s3-stack \
  --template-body file://templates/s3.yaml
```

See the 

```shell
aws cloudformation describe-stack-events --stack-name my-s3-stack
```