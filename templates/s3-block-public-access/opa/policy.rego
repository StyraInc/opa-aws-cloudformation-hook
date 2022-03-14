package policy

import future.keywords


s3BucketName := object.get(input.resource.properties, "BucketName", "<unknown>")

bucketExcluded(name) {
	some prefix in {"excluded-", "baseline-"}
	startswith(name, prefix)
}

publicAccessBlocked {
    every property in ["BlockPublicAcls", "BlockPublicPolicy", "IgnorePublicAcls", "RestrictPublicBuckets"] {
        input.resource.properties.PublicAccessBlockConfiguration[property] == "true"
    }
}

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    not bucketExcluded(s3BucketName)
    not publicAccessBlocked

    msg := sprintf("public access not blocked for bucket %s", [input.resource.id])
}
