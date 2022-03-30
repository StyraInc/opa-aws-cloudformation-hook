package aws.rds.dbinstance

import future.keywords

deny[msg] {
	not valid_storage_encryption
	msg := sprintf("storage encryption not enabled for: %s", [input.resource.id])
}

valid_storage_encryption {
	input.resource.properties.StorageEncrypted == "true"
}
