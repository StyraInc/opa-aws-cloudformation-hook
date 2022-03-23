package aws.rds.encryption_verify.tests

import future.keywords

import data.aws.rds.encryption_verify.deny

mock_create := {
    "action": "CREATE",
    "hook": "Styra::OPA::Hook",
    "resource": {
        "id": "RDSInstance",
        "name": "AWS::RDS::DBInstance",
        "type": "AWS::RDS::DBInstance",
        "properties": {
			"DBName": "OPA-DB",
            "Engine": "MySQL"
        }
    }
}
with_properties(obj) = {"resource": {"properties": obj}}

test_deny_storage_encryption_disabled {
	inp := object.union(mock_create, with_properties({
        "StorageEncrypted": false
    }))
    
    deny["storage encryption not enabled for: RDSInstance"] with input as inp
}

test_deny_storage_encryption_not_set {
    deny["storage encryption not enabled for: RDSInstance"] with input as mock_create
}

test_allow_storage_encryption_enabled {
	inp := object.union(mock_create, with_properties({
        "StorageEncrypted": true
    }))
    
    count(deny) == 0 with input as inp
}
