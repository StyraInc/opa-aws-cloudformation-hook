package aws.sg.open_ingress

import future.keywords

CidrIp := input.resource.properties.SecurityGroupIngress[0].CidrIp
CidrIpv6 := input.resource.properties.SecurityGroupIngress[0].CidrIpv6

deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::EC2::SecurityGroup"

    CidrIp == "0.0.0.0/0"

    msg := sprintf("Security Group cannot contain rules allow all destinations (0.0.0.0/0 or ::/0): %s", [input.resource.id])
}
deny[msg] {
    input.action in {"CREATE", "UPDATE"}
    input.resource.type == "AWS::EC2::SecurityGroup"

    CidrIpv6 == "::/0"

    msg := sprintf("Security Group cannot contain rules allow all destinations (0.0.0.0/0 or ::/0): %s", [input.resource.id])
}