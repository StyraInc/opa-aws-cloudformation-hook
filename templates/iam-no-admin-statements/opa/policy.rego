package aws.iam.no_admin

import future.keywords

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::IAM::User"
    not valid_iam_scope

    msg := sprintf("please limit the scope for IAM user: %s", [input.resource.id])
}

valid_iam_scope {
	input.resource.properties.Policies[_].PolicyDocument.Statement[_].Action != "'*'"
}
