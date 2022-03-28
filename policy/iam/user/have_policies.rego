package aws.iam.user

import future.keywords

deny[msg] {
	not user_policies_exist

	msg := sprintf("IAM user does not have a policy statement: %s", [input.resource.id])
}

user_policies_exist {
	input.resource.properties.Policies
}

user_policies_exist {
	input.resource.properties.ManagedPolicyArns
}
