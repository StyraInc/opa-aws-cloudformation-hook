package aws.s3.bucket_logging.tests

import future.keywords

import data.aws.s3.bucket_logging.deny


mock_create := {
    "action": "CREATE",
    "hook": "Styra::OPA::Hook",
    "resource": {
        "id": "MyS3Bucket",
        "name": "AWS::S3::Bucket",
        "properties": {},
        "type": "AWS::S3::Bucket"
    }
}

with_properties(obj) = {"resource": {"properties": obj}}

test_deny_if_logging_prefix_invalid {
	inp := object.union(mock_create, with_properties({
        "LoggingConfiguration": {
        	"LogFilePrefix": "invalid"
        }
    }))

    deny["logging prefix is not set correctly for bucket: MyS3Bucket"] with input as inp
}
test_deny_if_logging_bucket_invalid {
	inp := object.union(mock_create, with_properties({
        "LoggingConfiguration": {
        	"DestinationBucketName": "invalid"
        }
    }))

    deny["logging destination bucket is not correct: MyS3Bucket"] with input as inp
}
test_deny_if_logging_configuration_unset {
    deny["logging destination bucket is not correct: MyS3Bucket"] with input as mock_create
    deny["logging prefix is not set correctly for bucket: MyS3Bucket"] with input as mock_create
}

test_allow_if_prefix_and_destination_set {
	inp := object.union(mock_create, with_properties({
        "LoggingConfiguration": {
        	"LogFilePrefix": "s3-logs",
        	"DestinationBucketName": "my-logging-bucket"
        }
    }))

    count(deny) == 0 with input as inp
}
test_allow_if_bucket_name_set {
	inp := object.union(mock_create, with_properties({
    	"BucketName": "My-Bucket",
        "LoggingConfiguration": {
        	"LogFilePrefix": "s3-logs-My-Bucket",
        	"DestinationBucketName": "my-logging-bucket"
        }
    }))

    count(deny) == 0 with input as inp
}

test_allow_if_delete {
	count(deny) == 0 with input as {
        "action": "DELETE",
        "hook": "Styra::OPA::Hook",
        "resource": {
            "id": "MyS3Bucket",
            "name": "AWS::S3::Bucket",
            "properties": {
            },
            "type": "AWS::S3::Bucket"
        }
	}
}