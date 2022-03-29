package aws.s3.bucket

import future.keywords

deny[msg] {
	not valid_logging_prefix
	msg := sprintf("logging prefix is not set correctly for bucket: %s", [input.resource.id])
}

deny[msg] {
	not valid_logging_destination
	msg := sprintf("logging destination bucket is not correct: %s", [input.resource.id])
}

valid_logging_prefix {
	input.resource.properties.LoggingConfiguration.LogFilePrefix == concat("-", ["s3-logs", input.resource.properties.BucketName])
}

valid_logging_prefix {
	not input.resource.properties.BucketName
	input.resource.properties.LoggingConfiguration.LogFilePrefix == "s3-logs"
}

valid_logging_destination {
	input.resource.properties.LoggingConfiguration.DestinationBucketName == "my-logging-bucket"
}
