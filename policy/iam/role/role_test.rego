package aws.iam.tests

import future.keywords

import data.aws.iam.deny

mock_create := {
    "action": "CREATE",
    "hook": "Styra::OPA::Hook",
    "resource": {
        "id": "IAMRoleTest",
        "name": "AWS::IAM::Role",
        "type": "AWS::IAM::Role",
        "properties": {
         	"AssumeRolePolicyDocument": {
        		"Version": "2012-10-17",
            	"Statement": [{
            		"Action": "sts:AssumeRole",
                	"Effect": "Allow",
                	"Principal": {
                		"Service": "codepipeline.amazonaws.com"
            }}]}
        }
    }
}

with_properties(obj) = {"resource": {"properties": obj}}

test_deny_auto_generated_name_not_excluded {
	inp := object.union(mock_create, with_properties({
        "RoleName": "iam-not-excluded-cfn-hooks-cfn-stack-1-fail-046693375555",
        "PermissionsBoundary": "arn:aws:iam::555555555555:policy/invalid_s3_deny_permissions_boundary"
    }))

    deny["PermissionsBoundary arn:aws:iam::555555555555:policy/invalid_s3_deny_permissions_boundary is not allowed for IAMRoleTest"] with input as inp
}

test_deny_permission_boundary_not_set {
	inp := mock_create

    deny["PermissionsBoundary is not set for IAMRoleTest"] with input as inp
}

test_allow_permission_boundary_included {
	inp := object.union(mock_create, with_properties({
        "RoleName": "cfn-hooks-pass-046693375555",
        "PermissionsBoundary": "arn:aws:iam::555555555555:policy/s3_deny_permissions_boundary"
    }))

    count(deny) == 0 with input as inp
}
test_allow_role_name_excluded {
	inp := object.union(mock_create, with_properties({
        "RoleName": "excluded-cfn-hooks-stack1-046693375555"
    }))

    count(deny) == 0 with input as inp
}

test_allow_user_name_excluded {
	inp := object.union(mock_create, with_properties({
        "UserName": "excluded-cfn-hooks-stack1-046693375555"
    }))

    count(deny) == 0 with input as inp
}