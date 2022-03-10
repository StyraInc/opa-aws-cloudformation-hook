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

Next, set the AWS region and the URL to use for calling OPA. I'm using [ngrok](https://ngrok.com/)
for exposing an OPA running locally to the public, but there are obviously many ways to accomplish this.

```shell
export AWS_REGION="eu-north-1"
export OPA_URL="http://206d-46-182-202-220.ngrok.io/v1/data/policy/deny"
```

Optionally, if using bearer token to authenticate against OPA, provide ARN pointing to the secret containing the token:
```shell
export OPA_AUTH_TOKEN_SECRET="arn:aws:secretsmanager:eu-north-1:677200501247:secret:opa-cfn-token-l26bHK"
```

With the configuration variables set, push the configuration to AWS (remove `opaAuthTokenSecret` if you don't intend to use it):

```shell
aws cloudformation --region "$AWS_REGION" set-type-configuration \
  --configuration "{\"CloudFormationConfiguration\":{\"HookConfiguration\":{\"TargetStacks\":\"ALL\",\"FailureMode\":\"FAIL\",\"Properties\":{\"opaUrl\": \"$OPA_URL\",\"opaAuthTokenSecret\":\"$OPA_AUTH_TOKEN_SECRET\"}}}}" \
  --type-arn $HOOK_TYPE_ARN
```

## Testing stack creation

The hook is now installed. You can now try to push the S3 bucket stack provided in the templates directory:

```shell
aws cloudformation create-stack --stack-name cfn-s3 --template-body file://templates/s3.yaml
```

To see the outcome of the stack creation, use `describe-stack-events`:

```shell
aws cloudformation describe-stack-events --stack-name cfn-s3
```

If you want to re-run the stack creation, remember to delete the existing one first:

```shell
aws cloudformation delete-stack --stack-name cfn-s3
```

Or update the stack:

```shell
aws cloudformation update-stack --stack-name cfn-s3 --template-body file://templates/s3.yaml
```

## Rego Policy

The OPA configured to receive requests from the CFN hook will have its input provided in this format:

```json
{
  "input": {
    "action": "CREATE",
    "hook": "Styra::OPA::Hook",
    "resource": {
      "id": "MyS3Bucket",
      "name": "AWS::S3::Bucket",
      "type": "AWS::S3::Bucket",
      "properties": {"Tags": [{"Value": "Anders", "Key": "Owner"}]}
    }
  }
}
```

Some notes on the above format:
* The "action" is either "CREATE", "UPDATE" or "DELETE"
* I'm not sure whether "name" and "type" ever differs, but it seems like a good idea to provide both
* The properties are exactly as defined in the template - no generated or default values

The hook is currently hardcoded to deal with "deny" style policy responses, i.e. a **set** of messages.
If the set (as represented by a JSON array) is empty, the request is approved. If the set has any entries,
the request is denied, and the messages returned are logged to CloudWatch at error level.

### Example Policy

Example policy to ensure that an S3 bucket has an access control policy, and that policy is set to private:

```rego
package policy

import future.keywords

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    not input.resource.properties.AccessControl

    msg := sprintf("S3 bucket %s does not specify AccessControl attribute", [input.resource.id])
}

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    access_control := input.resource.properties.AccessControl
    access_control != "Private"

    msg := sprintf("S3 bucket %s AccessControl attribute set to a non-private value: %s", [input.resource.id, access_control])
}
```

## Logs

Any logs emitted from the Python hook can be found under CloudWatch in your AWS account.

## Authentication and Permissions

If configured to use a bearer token for authenticating against OPA, the hook will try to fetch the token from the
secret provided in the `opaAuthTokenSecret` (ARN) configuration attribute. Note that the token should be provided
as a plain string in the secret (i.e. the `SecretString`) and not wrapped in a JSON object.

In order to fetch the token, the hook will need to be permitted to perform the `secretsmanager:GetSecretValue`
operation. Note that the hook will **only** read the secret provided by `opaAuthTokenSecret`, but it's recommended
to limit the `HookTypePolicy` on the IAM role to the specific secret accessed, i.e. the same ARN provided in
`opaAuthTokenSecret`. If you aren't planning to use bearer tokens for authentication, you may remove the permission entirely.

Example `HookTypePolicy` to allow the hook access to a specific secret:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:eu-north-1:677200501247:secret:opa-cfn-token-l26bHK"
        }
    ]
}
```

### OPA Authentication Configuration

OPA may now be configured to require authentication to access the REST API, as described in the OPA
[documentation](https://www.openpolicyagent.org/docs/latest/security/#authentication-and-authorization).

A simple authz policy for checking the bearer token might look something like this:

```rego
package system.authz

default allow = false

allow {
    input.identity == "my_secret_token"
}
```

Remember to pass the appropriate flags to `opa run` to enable authentication / authorization:

```shell
opa run --server --authentication=token --authorization=basic .
```

## Docs

See docs on registering the hook here:
https://docs.aws.amazon.com/cloudformation-cli/latest/userguide/registering-hook-python.html

To see all attributes an object (like say, and S3 bucket) may have, consult the AWS resource type ref:
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html


## Open Questions

* Authentication - if OPA is running in public, how do we provide credentials? Or may we assume
  that the OPA is running in the same AWS environment and has been secured by other means, like
  via network policy, etc?
* Should we allow configuration of the expected response, i.e. "allow" vs. "deny"?
* Working with existing resources (like only allow resource X if resource Y does not exist). The
  libraries available for Java and Python can easily use the AWS SDK to call out to the AWS API,
  but we don't have a good story for that in Rego currently.
