# OPA AWS CloudFormation Hook

This repository integrates AWS Cloud Formation (CFN) with OPA using [AWS Cloud Formation Hooks](https://aws.amazon.com/about-aws/whats-new/2022/02/aws-announces-general-availability-aws-cloudformation-hooks/). Use this integration if you want to enforce policies over AWS resources (e.g., EC2 instances, S3 buckets, etc.) provisioned with CFN. For example, using this integration you can secure any of the following plus more:

* [EC2 Security Groups](https://github.com/StyraInc/opa-aws-cloudformation-hook/blob/main/policy/ec2/security_group/security_group.rego)
* [IAM Admin Rules](https://github.com/StyraInc/opa-aws-cloudformation-hook/blob/main/policy/iam/user/no_admin_test.rego)
* [S3 Public Access](https://github.com/StyraInc/opa-aws-cloudformation-hook/blob/main/policy/s3/bucket/public_access_test.rego)

> AWS Cloud Formation Hooks were added in February 2022. The feature is still relatively new for AWS Cloud Formation. If you run into any issues please report them [here](https://github.com/StyraInc/opa-aws-cloudformation-hook/issues).

## How it works

First, you will need an [AWS HOOK](https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/hooks-structure.html); when creating, updating, or deleting a CloudFormation Stack, you can trigger this Hook to validate the configuration. When used in conjunction with OPA, the Hook will send the property information from each resource in a Stack to your OPA server. When this information is received, OPA will validate the request against your defined policies and send back any violations it may have found. Then, depending on your configuration, you can either stop the action a stack was attempting or log the violation. 

Want to try out this integration yourself? See the AWS Cloud Formation Hooks tutorial in the [OPA documentation](https://github.com/open-policy-agent/opa/blob/main/docs/content/aws-cloudformation-hooks.md).
