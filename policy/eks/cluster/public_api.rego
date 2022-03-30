package aws.eks.cluster

import future.keywords

deny[msg] {
	not public_endpoint_disabled
	msg := sprintf("public endpoint needs to be disabled for cluster: %s", [input.resource.id])
}

deny[msg] {
	public_endpoint_disabled
	not private_endpoint_enabled
	msg := sprintf("invalid configuration, please enable private api for cluster: %s", [input.resource.id])
}

public_endpoint_disabled {
	input.resource.properties.ResourcesVpcConfig.EndpointPublicAccess == "false"
}

private_endpoint_enabled {
	input.resource.properties.ResourcesVpcConfig.EndpointPrivateAccess == "true"
}
