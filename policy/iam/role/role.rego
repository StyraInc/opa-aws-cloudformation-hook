package aws.iam

import future.keywords

excludedPrincipalPrefixes := ["excluded", "iam-excluded", "test-excluded-user"]

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    iam_resource_type
    not excluded_principal_name
    not permission_boundary_exists

    msg := sprintf("PermissionsBoundary is not set for %s", [input.resource.id])
}
excluded_principal_name {
    name := input.resource.properties.UserName
    some prefix in excludedPrincipalPrefixes
    startswith(name, prefix)
}
excluded_principal_name {
    name := input.resource.properties.RoleName
    some prefix in excludedPrincipalPrefixes
    startswith(name, prefix)
}
permission_boundary_exists {
    input.resource.properties.PermissionsBoundary
}

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    iam_resource_type
    not excluded_principal_name
    permission_boundary_exists
    not valid_permission_boundary

    msg := sprintf("PermissionsBoundary %s is not allowed for %s", [input.resource.properties.PermissionsBoundary, input.resource.id])
}
iam_resource_type {
    input.resource.type == "AWS::IAM::Role"
}
iam_resource_type {
    input.resource.type == "AWS::IAM::User"
}
valid_permission_boundary {
    input.resource.properties.PermissionsBoundary == "arn:aws:iam::555555555555:policy/s3_deny_permissions_boundary"
}
