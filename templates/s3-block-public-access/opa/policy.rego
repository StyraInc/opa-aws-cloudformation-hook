package aws.s3.block_public_access

import future.keywords

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    not bucket_excluded
    not public_access_blocked

    msg := sprintf("public access not blocked for bucket %s", [input.resource.id])
}

bucket_excluded {
    s3BucketName := input.resource.properties.BucketName
	some prefix in {"excluded-", "baseline-"}
	startswith(s3BucketName, prefix)
}

public_access_blocked {
    every property in ["BlockPublicAcls", "BlockPublicPolicy", "IgnorePublicAcls", "RestrictPublicBuckets"] {
        input.resource.properties.PublicAccessBlockConfiguration[property] == "true"
    }
}
