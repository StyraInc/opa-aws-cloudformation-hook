# Cloudformation

* A Template is equivalent to a .tf file - i.e. describing the resources to be provisioned
* A Stack provisions the resources described in a template

```shell
aws cloudformation create-stack --stack-name cfn-s3 --template-body file://templates/s3.yaml
aws cloudformation describe-stack-events --stack-name cfn-s3

# After changes
aws cloudformation update-stack --stack-name demo-s3 --template-body file://s3.yaml
```
