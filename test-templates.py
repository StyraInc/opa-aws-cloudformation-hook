#!/usr/bin/env python3

import os

import requests
import json

from cfn_flip import to_json

def get_all_templates():
    templates = []

    for root, _, files in os.walk("templates"):
        for file in files:
            templates.append(os.path.join(root, file))

    return templates


def check_resource(path, name, resource, expect_allow):
    properties = bools_to_string(resource["Properties"])

    opa_input = {
        "action": "CREATE",
        "hook": "Styra::OPA::Hook",
        "resource": {
            "id": name,
            "name": resource["Type"],
            "type": resource["Type"],
            "properties": properties
        }
    }

    resp = requests.post("http://localhost:8181", json=opa_input)

    decision = resp.json()

    if decision["allow"] == expect_allow:
        print(f"SUCCESS: {path} {name}")
    else:
        print(f"FAIL: {path} {name}")

        if len(decision["violations"]) > 0:
            print()

        for violation in decision["violations"]:
            print(f"\t{violation}")

        if len(decision["violations"]) > 0:
            print()


def check_template(path):
    contents = {}
    try:
        with open(path) as file:
            contents = json.loads(to_json(file.read(), clean_up=True))


    except Exception as e:
        print(f"ERROR: Exception raised when loading {path}", e)
        return

    resources = contents["Resources"]
    resource_names = list(resources.keys())

    for name in resource_names:
        # Some templates contain resources which we don't intend to test
        # For those we may use an "ObjectToTest" attribute in the templates
        # metadata section to point out which object should be verified.
        if "Metadata" in contents and "ObjectToTest" in contents["Metadata"]:
            if name == contents["Metadata"]["ObjectToTest"]:
                check_resource(path, name, resources[name], "success" in path)
            else:
                continue

        check_resource(path, name, resources[name], "success" in path)


# When presented to the hook, AWS templates converts booleans to strings...
#
# ¯\_(ツ)_/¯
#
def bools_to_string(obj):
    for k, v in obj.items():
        if isinstance(v, dict):
            bools_to_string(v)
        if isinstance(v, list):
            for item in v:
                if isinstance(item, dict):
                    bools_to_string(item)

        if isinstance(v, bool):
            obj[k] = "false" if not v else "true"

    return obj


def main():
    templates = get_all_templates()

    for template in templates:
        check_template(template)


if __name__ == "__main__":
    main()
