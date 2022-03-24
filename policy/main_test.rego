package main_test

import data.system.main

test_simple_routing {
    expected := {
        "allow": false,
        "violations": {
            "test violation"
        }
    }

    main == expected with input as {
        "action": "CREATE",
        "resource": {
            "type": "AWS::S3::Bucket"
        }
    } with data.aws as {
        "s3": {
            "bucket": {
                "deny": {"test violation"}
            }
        }
    }
}

test_input_validation {
    main.violations["Missing input.action"] with input as {}
    main.violations["Missing input.resource"] with input as {}
    main.violations["Missing input.resource.type"] with input as {}
}