package aws.s3.bucket_public_access_test

import future.keywords

import data.aws.s3.bucket.deny

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

test_deny_if_not_public_access_blocked {
	inp := object.union(mock_create, with_properties({
        "PublicAccessBlockConfiguration": {
        	"BlockPublicAcls": "false",
            "BlockPublicPolicy": "true",
            "IgnorePublicAcls": "true",
            "RestrictPublicBuckets": "false",
        }
    }))

    deny["public access not blocked for bucket MyS3Bucket"] with input as inp
}

test_allow_if_public_access_blocked {
	inp := object.union(mock_create, with_properties({
        "PublicAccessBlockConfiguration": {
        	"BlockPublicAcls": "true",
            "BlockPublicPolicy": "true",
            "IgnorePublicAcls": "true",
            "RestrictPublicBuckets": "true",
        }
    }))

    not deny["public access not blocked for bucket MyS3Bucket"] with input as inp
}

test_allow_if_excluded_prefix {
	not deny["public access not blocked for bucket MyS3Bucket"] with input as object.union(mock_create, with_properties({
    	"BucketName": "excluded-bucket"
    }))
}
