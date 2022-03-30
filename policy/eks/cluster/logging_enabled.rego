package aws.eks.cluster

import future.keywords

deny[msg] {
	not cluster_logging_enabled
	msg := sprintf("no logging types are enabled for cluster: %s", [input.resource.id])
}

cluster_logging_enabled {
	count(input.resource.properties.Logging.ClusterLogging.EnabledTypes) > 0
}
