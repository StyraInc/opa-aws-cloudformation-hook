package policy.tests

import future.keywords

import data.policy.deny

mock_create := {
    "action": "CREATE",
    "hook": "StyraOPA::SecurityGroup::Hook",
    "resource": {
        "id": "SecurityGroup",
        "name": "AWS::EC2::SecurityGroup",
        "properties": {},
        "type": "AWS::EC2::SecurityGroup"
    }
}

with_properties(obj) = {"resource": {"properties": obj}}

test_deny_if_security_group_allows_all_destinations {
	inp := object.union(mock_create, with_properties({
        "SecurityGroupIngress": [
            {
                "CidrIp": "0.0.0.0/0",
                "IpProtocol": "-1"
            }
        ]
    }))

    deny["Security Group cannot contain rules allow all destinations (0.0.0.0/0 or ::/0): SecurityGroup"] with input as inp
}

test_allow_if_security_group_cidr_is_set {
	inp := object.union(mock_create, with_properties({
        "SecurityGroupIngress": [
            {
                "CidrIp": "10.0.0.0/16",
                "IpProtocol": "-1"
            }
        ]
    }))

    count(deny) == 0 with input as inp
}

