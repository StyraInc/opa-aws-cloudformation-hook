package policy

import future.keywords

BucketEncryption := object.get(input.resource.properties, "BucketEncryption", "<undefined>")
SSEAlgorithm := object.get(input.resource.properties.BucketEncryption.ServerSideEncryptionConfiguration[0].ServerSideEncryptionByDefault, "SSEAlgorithm", "<undefined>")

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    BucketEncryption == "<undefined>"

    msg := sprintf("bucket encryption is not enabled for bucket: %s", [input.resource.id])
}

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    SSEAlgorithm != "aws:kms"

    msg := sprintf("encryption not set to aws:kms for bucket: %s", [input.resource.id])
}
