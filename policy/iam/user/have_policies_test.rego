package aws.iam.user_have_policies_test

import future.keywords

import data.aws.iam.user.deny

import data.test_helpers.assert_empty
import data.test_helpers.create_with_properties
import data.test_helpers.with_properties

mock_create := create_with_properties("AWS::IAM::User", "IAMUserTest", {
	"Policies": [{"PolicyDocument": {
		"PolicyName": "Test",
		"Statement": [{
			"Action": "'*'",
			"Effect": "Deny",
			"Resource": "'*'",
		}],
		"Version": "2012-10-17",
	}}],
	"UserName": "WithPolicy",
})

test_deny_policy_statement_undefined {
	inp := create_with_properties("AWS::IAM::User", "IAMUserTest", {"AssumeRolePolicyDocument": {
		"Version": "2012-10-17",
		"Statement": [{
			"Action": "sts:AssumeRole",
			"Effect": "Allow",
			"Principal": {"Service": "codepipeline.amazonaws.com"},
		}],
	}})

	deny["IAM user does not have a policy statement: IAMUserTest"] with input as inp
}

test_allow_user_with_policy {
	inp := create_with_properties("AWS::IAM::User", "IAMUserTest", {
		"Policies": [{"PolicyDocument": {
			"PolicyName": "Test",
			"Statement": [{
				"Action": "'*'",
				"Effect": "Deny",
				"Resource": "'*'",
			}],
			"Version": "2012-10-17",
		}}],
		"UserName": "WithPolicy",
	})

	count(deny) == 0 with input as inp
}

test_allow_user_with_managed_policy {
	inp := create_with_properties("AWS::IAM::User", "IAMUserTest", {"ManagedPolicyArns": ["arn:aws:iam::aws:policy/AWSDenyAll"]})

	count(deny) == 0 with input as inp
}
