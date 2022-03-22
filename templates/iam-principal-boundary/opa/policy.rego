package policy.iamPrincipalBoundary

import future.keywords

UserName := object.get(input.resource.properties, "UserName", "<undefined>")
RoleName := object.get(input.resource.properties, "RoleName", "<undefined>")
PermissionsBoundary := object.get(input.resource.properties, "PermissionsBoundary", "<undefined>")

excludedPrincipalPrefixes := ["excluded", "iam-excluded", "test-excluded-user"]
iamPrincipalBoundaryArn := "arn:aws:iam::555555555555:policy/s3_deny_permissions_boundary"


isPrincipalExcluded {
    some prefix in excludedPrincipalPrefixes
    startswith(UserName, prefix)
}
isPrincipalExcluded {
    some prefix in excludedPrincipalPrefixes
    startswith(RoleName, prefix)
}

deny[msg] {
    not isPrincipalExcluded
    PermissionsBoundary != iamPrincipalBoundaryArn

    msg := sprintf("PermissionsBoundary %s is not allowed for %s", [PermissionsBoundary, input.resource.id])
}

deny[msg] {
    not isPrincipalExcluded
    PermissionsBoundary == "<undefined>"

    msg := sprintf("PermissionsBoundary is not set for %s", [input.resource.id])
}
