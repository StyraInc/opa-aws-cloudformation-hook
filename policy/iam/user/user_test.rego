package aws.iam.user_test

import future.keywords

import data.aws.iam.user.deny

import data.test_helpers.assert_empty
import data.test_helpers.create_with_properties
import data.test_helpers.with_properties

mock_create := create_with_properties("AWS::IAM::User", "IAMUserTest", {
    "AssumeRolePolicyDocument": {
        "Version": "2012-10-17",
        "Statement": [{
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "codepipeline.amazonaws.com"
            }
        }]
    }
})

test_deny_auto_generated_name_not_excluded {
	inp := object.union(mock_create, with_properties({
        "RoleName": "iam-not-excluded-cfn-hooks-cfn-stack-1-fail-046693375555",
        "PermissionsBoundary": "arn:aws:iam::555555555555:policy/invalid_s3_deny_permissions_boundary"
    }))

    deny["PermissionsBoundary arn:aws:iam::555555555555:policy/invalid_s3_deny_permissions_boundary is not allowed for IAMUserTest"] with input as inp
}

test_deny_permission_boundary_not_set {
	inp := mock_create

    deny["PermissionsBoundary is not set for IAMUserTest"] with input as inp
}

test_allow_permission_boundary_included {
	inp := object.union(mock_create, with_properties({
        "RoleName": "cfn-hooks-pass-046693375555",
        "PermissionsBoundary": "arn:aws:iam::555555555555:policy/s3_deny_permissions_boundary"
    }))

    assert_empty(deny) with input as inp
}

test_allow_user_name_excluded {
	inp := object.union(mock_create, with_properties({
        "UserName": "excluded-cfn-hooks-stack1-046693375555"
    }))

    assert_empty(deny) with input as inp
}