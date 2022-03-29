#!/usr/bin/env python3

import os

import requests
import yaml
import typing

def get_all_templates():
    templates = []

    for root, _, files in os.walk("templates"):
        for file in files:
            templates.append(os.path.join(root, file))

    return templates


def check_resource(path, name, resource, expect_allow):
    properties = resource["Properties"]

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
        print(f"SUCCESS: {path}")
    else:
        print(f"FAIL: {path}")

class Loader(yaml.SafeLoader):
    pass

class Dumper(yaml.SafeDumper):
    pass

class Tagged(typing.NamedTuple):
    tag: str
    value: object

def construct_undefined(self, node):
    if isinstance(node, yaml.nodes.ScalarNode):
        value = self.construct_scalar(node)
    elif isinstance(node, yaml.nodes.SequenceNode):
        value = self.construct_sequence(node)
    elif isinstance(node, yaml.nodes.MappingNode):
        value = self.construct_mapping(node)
    else:
        assert False, f"unexpected node: {node!r}"
    return Tagged(node.tag, value)

Loader.add_constructor(None, construct_undefined)

def check_template(path):
    contents = ""
    try:
        with open(path) as file:
            contents = yaml.load(file, Loader=Loader)
    except Exception as e:
        print(f"ERROR: Exception raised when loading {path}", e)
        return

    resources = contents["Resources"]
    resource_names = list(resources.keys())

    for name in resource_names:
        check_resource(path, name, resources[name], "success" in path)


def main():
    templates = get_all_templates()

    for template in templates:
        check_template(template)


if __name__ == "__main__":
    main()
