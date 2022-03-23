package aws.s3.bucket_encryption.tests

import future.keywords

import data.aws.s3.bucket_encryption.deny

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

test_deny_if_bucket_encryption_not_set {
	inp := object.union(mock_create, with_properties({
        "BucketEncryption": {}
    }))

    deny["bucket encryption is not enabled for bucket: MyS3Bucket"] with input as inp
}
test_deny_if_bucket_encryption_is_not_aws_kms {
	inp := object.union(mock_create, with_properties({
        "BucketEncryption": {
        	"ServerSideEncryptionConfiguration": [
                {"ServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:invalid"
                } }
            ]
        }
    }))

    deny["encryption not set to aws:kms for bucket: MyS3Bucket"] with input as inp
}

test_allow_if_bucket_encryption_is_set {
	inp := object.union(mock_create, with_properties({
        "BucketEncryption": {
        	"ServerSideEncryptionConfiguration": [
                {"ServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms"
                } }
            ]
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