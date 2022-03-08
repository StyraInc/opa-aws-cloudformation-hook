# Cloudformation

* A Template is equivalent to a .tf file - i.e. describing the resources to be provisioned
* A Stack provisions the resources described in a template

```shell
aws cloudformation create-stack --stack-name cfn-s3 --template-body file://templates/s3.yaml
aws cloudformation describe-stack-events --stack-name cfn-s3

# After changes
aws cloudformation update-stack --stack-name demo-s3 --template-body file://s3.yaml
```

See docs on registering the hook here:
https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/registering-hook-python.html


```shell
aws cloudformation --region eu-north-1 set-type-configuration \
  --configuration "{\"CloudFormationConfiguration\":{\"HookConfiguration\":{\"TargetStacks\":\"ALL\",\"FailureMode\":\"FAIL\",\"Properties\":{\"OpaUrl\": \"http://206d-46-182-202-220.ngrok.io/v1/data/policy/deny\"}}}}" \
  --type-arn $HOOK_TYPE_ARN
```

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