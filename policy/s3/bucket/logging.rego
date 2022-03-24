package aws.s3.bucket_logging

import future.keywords

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"
	not valid_logging_prefix
    msg := sprintf("logging prefix is not set correctly for bucket: %s", [input.resource.id])
}

valid_logging_prefix {
    input.resource.properties.LoggingConfiguration.LogFilePrefix == concat("-", ["s3-logs", input.resource.properties.BucketName])
}

valid_logging_prefix {
	not input.resource.properties.BucketName
    input.resource.properties.LoggingConfiguration.LogFilePrefix == "s3-logs"
}

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::S3::Bucket"
	not valid_logging_destination
    msg := sprintf("logging destination bucket is not correct: %s", [input.resource.id])
}

valid_logging_destination {
	input.resource.properties.LoggingConfiguration.DestinationBucketName == "my-logging-bucket"
}
