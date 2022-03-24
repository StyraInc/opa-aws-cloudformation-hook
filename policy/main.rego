# METADATA
# description: |
#   Dynamic routing to policy based in input.resource.type,
#   aggregating the deny rules found in all policies with a
#   matching package name
#
package system

import future.keywords

main := {
	"allow": count(violations) == 0,
	"violations": violations,
}

# METADATA
# description: |
#   Main routing logic, simply converting input.resource.type, e.g.
#   AWS::S3::Bucket to data.aws.s3.bucket and returning that document.
#
#   By default, only input.action == "CREATE" | "UPDATE" will be routed
#   to the data.aws.s3.bucket document. If handling "DELETE" actions is
#   desirable, one may create a special policy for that by simply appending
#   "delete" to the package name, e.g. data.aws.s3.bucket.delete
#
route := document(lower(component), lower(type)) {
	["AWS", component, type] = split(input.resource.type, "::")
}


violations[msg] {
    # Aggregate all deny rules found in routed document
    some msg in route.deny
}

#
# Basic input validation to avoid having to do this in each resource policy
#

violations["Missing input.resource"] {
	not input.resource
}

violations["Missing input.resource.type"] {
	not input.resource.type
}

violations["Missing input.resource.id"] {
	not input.resource.id
}

violations["Missing input.action"] {
	not input.action
}

#
# Helpers
#

document(component, type) = data.aws[component][type] {
	input.action != "DELETE"
}

document(component, type) = data.aws[component][type].delete {
	input.action == "DELETE"
}
