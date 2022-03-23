package aws.iam.user_policy.tests

import future.keywords

import data.aws.iam.user_policy.deny

mock_create := {
        "action": "CREATE",
        "hook": "Styra::OPA::Hook",
        "resource": {
            "id": "IAMUserTest",
            "name": "AWS::IAM::User",
            "properties": {},
            "type": "AWS::IAM::User"
        }
    }

with_properties(obj) = {"resource": {"properties": obj}}

test_deny_policy_statement_undefined {
    deny["IAM user does not have a policy statement: IAMUserTest"] with input as mock_create
}

test_allow_user_with_policy {
	inp := object.union(mock_create, with_properties({
                "Policies": [
                    {
                        "PolicyDocument": {
                            "PolicyName": "Test",
                            "Statement": [
                                {
                                    "Action": "'*'",
                                    "Effect": "Deny",
                                    "Resource": "'*'"
                                }
                            ],
                            "Version": "2012-10-17"
                        }
                    }
                ],
                "UserName": "WithPolicy"
            }))
            
    count(deny) == 0 with input as inp
}
test_allow_user_with_managed_policy {
	inp := object.union(mock_create, with_properties({
                "ManagedPolicyArns": ["arn:aws:iam::aws:policy/AWSDenyAll"]
            }))
            
    count(deny) == 0 with input as inp
}
