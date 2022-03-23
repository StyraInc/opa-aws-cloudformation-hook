package aws.iam.no_admin.tests

import future.keywords

import data.aws.iam.no_admin.deny

mock_create := {
        "action": "CREATE",
        "hook": "Styra::OPA::Hook",
        "resource": {
            "id": "IAMAdminTest",
            "name": "AWS::IAM::User",
            "properties": {},
            "type": "AWS::IAM::User"
        }
    }

with_properties(obj) = {"resource": {"properties": obj}}

test_deny_policy_statement_undefined {
    deny["please limit the scope for IAM user: IAMAdminTest"] with input as mock_create
}

test_deny_user_with_admin {
	inp := object.union(mock_create, with_properties({
                "Policies": [
                    {
                        "PolicyDocument": {
                            "PolicyName": "Test",
                            "Statement": [
                                {
                                    "Action": "'*'",
                                    "Effect": "Allow",
                                    "Resource": "'*'"
                                }
                            ],
                            "Version": "2012-10-17"
                        }
                    }
                ],
                "UserName": "WithInlineAdminPolicy"
            }))
            
    deny["please limit the scope for IAM user: IAMAdminTest"] with input as inp

}

test_allow_user_limited_scope {
	inp := object.union(mock_create, with_properties({
                "Policies": [
                    {
                        "PolicyDocument": {
                            "PolicyName": "Test",
                            "Statement": [
                                {
                                    "Action": "'ec2:*'",
                                    "Effect": "Allow",
                                    "Resource": "'*'"
                                }
                            ],
                            "Version": "2012-10-17"
                        }
                    }
                ],
                "UserName": "WithInlineEc2Policy"
            }))

    count(deny) == 0 with input as inp
}
