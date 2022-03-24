# METADATA
# description: |
#   Optional authorization policy to use for protecting the OPA REST API if
#   exposed on a public endpoint.
# related_resources:
# - description: OPA documentation on authentication and authorization
#   ref: https://www.openpolicyagent.org/docs/latest/security/#authentication-and-authorization
#
package system.authz

default allow = false

# METADATA
# description: |
#   See the README.md file contained in this repo for how to configure an AWS Secret to
#   use as a token for client connections.
#
allow {
    input.identity == "changeme"
}