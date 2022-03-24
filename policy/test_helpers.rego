package test_helpers

assert_equals(expected, result) {
	expected == result
}

assert_equals(expected, result) = false {
	expected != result
	print("expected:", expected, "got:", result)
}

assert_empty(coll) {
    count(coll) == 0
}

assert_empty(coll) = false {
    count(coll) != 0
    print("expected empty", type_name(coll), "got", coll)
}

create_with_properties(type, id, properties) = object.union(mock_create(type, id), with_properties(properties))

mock_create(type, id) = {
    "action": "CREATE",
    "hook": "StyraOPA::OPA::Hook",
    "resource": {
        "id": id,
        "name": type,
        "properties": {},
        "type": type,
    }
}

with_properties(obj) = {"resource": {"properties": obj}}
