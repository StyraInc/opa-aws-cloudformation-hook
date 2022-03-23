package aws.rds.encryption_verify

import future.keywords

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::RDS::DBInstance"
	not valid_storage_encryption
    msg := sprintf("storage encryption not enabled for: %s", [input.resource.id])
}

valid_storage_encryption {
	input.resource.properties.StorageEncrypted == true
}
