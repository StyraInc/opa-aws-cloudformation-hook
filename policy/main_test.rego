package main_test

import data.system.main

import data.test_helpers.assert_equals

test_simple_routing_deny {
	inp := {"action": "CREATE", "resource": {"type": "AWS::S3::Bucket", "id": "foo"}}
	aws := {"s3": {"bucket": {"deny": {"test violation"}}}}

	assert_equals({"allow": false, "violations": {"test violation"}}, main) with input as inp with data.aws as aws
}

test_simple_routing_deny_many {
	inp := {"action": "CREATE", "resource": {"type": "AWS::S3::Bucket", "id": "foo"}}
	aws := {"s3": {"bucket": {"deny": {"foo", "bar", "baz"}}}}

	assert_equals({"allow": false, "violations": {"foo", "bar", "baz"}}, main) with input as inp with data.aws as aws
}

test_simple_routing_allow {
	inp := {"action": "CREATE", "resource": {"type": "AWS::S3::Bucket", "id": "foo"}}
	aws := {"s3": {"bucket": {"deny": {}}}}

	assert_equals({"allow": true, "violations": set()}, main) with input as inp with data.aws as aws
}

test_simple_routing_delete_allow {
	inp := {"action": "DELETE", "resource": {"type": "AWS::S3::Bucket", "id": "foo"}}
	aws := {"s3": {"bucket": {"deny": {"denied but not delete"}, "delete": {"deny": {}}}}}

	assert_equals({"allow": true, "violations": set()}, main) with input as inp with data.aws as aws
}

test_simple_routing_delete_deny {
	inp := {"action": "DELETE", "resource": {"type": "AWS::S3::Bucket", "id": "foo"}}
	aws := {"s3": {"bucket": {"deny": {"denied but not delete"}, "delete": {"deny": {"deny delete"}}}}}

	assert_equals({"allow": false, "violations": {"deny delete"}}, main) with input as inp with data.aws as aws
}

test_input_validation {
	main.violations["Missing input.action"] with input as {}
	main.violations["Missing input.resource"] with input as {}
	main.violations["Missing input.resource.id"] with input as {}
	main.violations["Missing input.resource.type"] with input as {}
}
