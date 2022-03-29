package aws.iam.user

import future.keywords

deny[msg] {
	not valid_iam_scope

	msg := sprintf("please limit the scope for IAM user: %s", [input.resource.id])
}

valid_iam_scope {
	every policy in input.resource.properties.Policies {
		every statement in policy.PolicyDocument.Statement {
			statement.Action != "'*'"
		}
	}
}
