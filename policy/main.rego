# METADATA
# description: |
#   sss
package system

import future.keywords

default main = {
    "allow": false,
    "violations": {"Policy evaluation failure"}
}

main = {
    "allow": count(violations) == 0,
    "violations": violations,
}

violations[msg] {
    [_, component, type] := split(input.resource.type, "::")
    some msg in document(lower(component), lower(type)).deny
}

violations["Missing input.resource.type"] {
    not input.resource.type
}

violations["Missing input.resource"] {
    not input.resource
}

violations["Missing input.action"] {
    not input.action
}

document(component, type) = object.remove(data.aws[component][type], ["delete"]) {
    input.action != "DELETE"
}

document(component, type) = data.aws[component][type]["delete"] {
    input.action == "DELETE"
}
