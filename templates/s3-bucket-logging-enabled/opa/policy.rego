package policy

import future.keywords

s3BucketName := object.get(input.resource.properties, "BucketName", "")

expectedLoggingPrefix = concat("-", ["s3-logs", s3BucketName]) {
	s3BucketName != ""
}

expectedLoggingPrefix = "s3-logs" {
	s3BucketName == ""
}

expectedDestinationBucketName := "my-logging-bucket"

bucketLoggingPrefix := object.get(input.resource.properties, ["LoggingConfiguration", "LogFilePrefix"], "<undefined>")
bucketLoggingDestination := object.get(input.resource.properties, ["LoggingConfiguration", "DestinationBucketName"], "<undefined>")

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    bucketLoggingPrefix != expectedLoggingPrefix

    msg := sprintf("logging prefix is not set correctly for bucket: %s", [input.resource.id])
}
deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"

    bucketLoggingDestination != expectedDestinationBucketName

    msg := sprintf("logging destination bucket is not correct: %s", [input.resource.id])
}
