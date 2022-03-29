package aws.rds.db_test

import future.keywords

import data.aws.rds.db.deny

import data.test_helpers.create_with_properties

test_deny_storage_encryption_disabled {
	inp := create_with_properties("AWS::RDS::DBInstance", "RDSInstance", {"StorageEncrypted": false})

	deny["storage encryption not enabled for: RDSInstance"] with input as inp
}

test_deny_storage_encryption_not_set {
	inp := create_with_properties("AWS::RDS::DBInstance", "RDSInstance", {"properties": {
		"DBName": "OPA-DB",
		"Engine": "MySQL",
	}})

	deny["storage encryption not enabled for: RDSInstance"] with input as inp
}

test_allow_storage_encryption_enabled {
	inp := create_with_properties("AWS::RDS::DBInstance", "RDSInstance", {"StorageEncrypted": true})

	count(deny) == 0 with input as inp
}
