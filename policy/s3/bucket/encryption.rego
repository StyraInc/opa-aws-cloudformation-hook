package aws.s3.bucket_encryption

import future.keywords

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"
    not valid_bucket_encryption
    msg := sprintf("bucket encryption is not enabled for bucket: %s", [input.resource.id])
}

valid_bucket_encryption {
	input.resource.properties.BucketEncryption != {}
}

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"
    not valid_sse_algo
    msg := sprintf("encryption not set to aws:kms for bucket: %s", [input.resource.id])
}

valid_sse_algo {
	input.resource.properties.BucketEncryption.ServerSideEncryptionConfiguration[0].ServerSideEncryptionByDefault.SSEAlgorithm == "aws:kms"
}
