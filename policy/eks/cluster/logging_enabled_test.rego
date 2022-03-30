package aws.eks.logging_enabled_test

import data.aws.eks.cluster.deny

import future.keywords

import data.assertions.assert_empty
import data.assertions.assert_in
import data.assertions.assert_not_in

import data.test_helpers.create_with_properties
import data.test_helpers.with_properties


test_allow_cluster_logging_enabled {
	inp := create_with_properties("AWS::EKS::Cluster", "EksCluster", {
		"ResourcesVpcConfig": {
			"RoleArn": "<MY_EKS_SERVICE_ROLE_ARN>",
			"SubnetIds": ["<MY_SUBNET_ID>"]
		},
		"Logging": {
			"ClusterLogging": {
				"EnabledTypes": [
					{"Type": "audit"},
					{"Type": "authenticator"}
				]
			}
		}
	})

	msg := "no logging types are enabled for cluster: EksCluster"
	assert_not_in(msg, deny) with input as inp
}
test_deny_no_logging_configuration {
	inp := create_with_properties("AWS::EKS::Cluster", "EksCluster", {
		"ResourcesVpcConfig": {
			"RoleArn": "<MY_EKS_SERVICE_ROLE_ARN>",
			"SubnetIds": ["<MY_SUBNET_ID>"]
		},
		"Logging": {
			"ClusterLogging": {
			}
		}
	})

	msg := "no logging types are enabled for cluster: EksCluster"
	assert_in(msg, deny) with input as inp
}
