package aws.s3.bucket

import future.keywords

deny[msg] {
	not bucket_excluded_encryption
	not valid_bucket_encryption
	msg := sprintf("bucket encryption is not enabled for bucket: %s", [input.resource.id])
}

deny[msg] {
	not bucket_excluded_encryption
	not valid_sse_algo
	msg := sprintf("encryption not set to aws:kms for bucket: %s", [input.resource.id])
}

valid_bucket_encryption {
	input.resource.properties.BucketEncryption != {}
}

valid_sse_algo {
	input.resource.properties.BucketEncryption.ServerSideEncryptionConfiguration[0].ServerSideEncryptionByDefault.SSEAlgorithm == "aws:kms"
}

bucket_excluded_encryption {
	some prefix in {"excluded-", "baseline-", "access-"}
	startswith(input.resource.properties.BucketName, prefix)
}
