package aws.s3.bucket_encryption_test

import future.keywords

import data.aws.s3.bucket.valid_bucket_encryption
import data.aws.s3.bucket.valid_sse_algo
import data.aws.s3.bucket.deny

import data.test_helpers.create_with_properties

test_deny_if_bucket_encryption_not_set {
	inp := create_with_properties("AWS::S3::Bucket", "MyS3Bucket", {
        "BucketEncryption": {}
    })

    deny["bucket encryption is not enabled for bucket: MyS3Bucket"] with input as inp
}

test_deny_if_bucket_encryption_is_not_aws_kms {
	inp := create_with_properties("AWS::S3::Bucket", "MyS3Bucket", {
        "BucketEncryption": {
        	"ServerSideEncryptionConfiguration": [
                {"ServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:invalid"
                }}
            ]
        }
    })

    deny["encryption not set to aws:kms for bucket: MyS3Bucket"] with input as inp
}

test_allow_if_bucket_encryption_is_set {
	inp := create_with_properties("AWS::S3::Bucket", "MyS3Bucket", {
        "BucketEncryption": {
        	"ServerSideEncryptionConfiguration": [
                {"ServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms"
                } }
            ]
        }
    })

    not deny["bucket encryption is not enabled for bucket: MyS3Bucket"] with input as inp
    not deny["encryption not set to aws:kms for bucket: MyS3Bucket"] with input as inp
}