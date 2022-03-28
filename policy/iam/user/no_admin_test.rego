package aws.iam.user_no_admin_test

import future.keywords

import data.aws.iam.user.deny

import data.test_helpers.assert_empty
import data.test_helpers.create_with_properties
import data.test_helpers.with_properties

mock_create := create_with_properties("AWS::IAM::User", "IAMUserTest", {"AssumeRolePolicyDocument": {
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Effect": "Allow",
		"Principal": {"Service": "codepipeline.amazonaws.com"},
	}],
}})

test_deny_policy_statement_undefined {
	inp := mock_create

	deny["please limit the scope for IAM user: IAMAdminTest"] with input as inp
}

test_deny_user_with_admin {
	inp := object.union(mock_create, with_properties({
		"Policies": [
			{"PolicyDocument": {
				"PolicyName": "Test1",
				"Statement": [{
					"Action": "'Create'",
					"Effect": "Allow",
					"Resource": "'*'",
				}],
				"Version": "2012-10-17",
			}},
			{"PolicyDocument": {
				"PolicyName": "Test2",
				"Statement": [{
					"Action": "'*'",
					"Effect": "Allow",
					"Resource": "'*'",
				}],
				"Version": "2012-10-17",
			}},
		],
		"UserName": "WithInlineAdminPolicy",
	}))

	deny["please limit the scope for IAM user: IAMAdminTest"] with input as inp
}

test_allow_user_limited_scope {
	inp := object.union(mock_create, with_properties({
		"Policies": [{"PolicyDocument": {
			"PolicyName": "Test",
			"Statement": [{
				"Action": "'ec2:*'",
				"Effect": "Allow",
				"Resource": "'*'",
			}],
			"Version": "2012-10-17",
		}}],
		"UserName": "WithInlineEc2Policy",
	}))

	count(deny) == 0 with input as inp
}
