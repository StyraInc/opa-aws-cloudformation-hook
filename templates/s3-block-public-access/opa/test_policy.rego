package policy.tests

import future.keywords


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
        	"BlockPublicAcls": false,
            "BlockPublicPolicy": true,
            "IgnorePublicAcls": true,
            "RestrictPublicBuckets": false        
        }
    }))
    
    deny["public access not blocked for bucket MyS3Bucket"] with input as inp
}

test_allow_if_public_access_blocked {
	inp := object.union(mock_create, with_properties({
        "PublicAccessBlockConfiguration": {
        	"BlockPublicAcls": true,
            "BlockPublicPolicy": true,
            "IgnorePublicAcls": true,
            "RestrictPublicBuckets": true        
        }
    }))
    
    count(deny) == 0 with input as inp
}

test_allow_if_excluded_suffix {
	count(deny) == 0 with input as object.union(mock_create, with_properties({
    	"BucketName": "this-bucket-is-public"
    }))
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