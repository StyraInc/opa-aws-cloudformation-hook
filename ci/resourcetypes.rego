package aws.cloudformation

import future.keywords

# METADATA
# description: |
#   Get all resource types from the single-file JSON schema provided by AWS for the us-west-1
#   region. See https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-resource-specification.html
#   for a list of all available files in all regions
resource_types[type] {
	some type, _ in http.send({
		"method": "GET",
		"url": "https://d68hl49wbnanq.cloudfront.net/latest/gzip/CloudFormationResourceSpecification.json",
	}).body.ResourceTypes
}

# METADATA
# description: |
#   Patch the provided input (the existing file) with the resource types provided at the AWS endpoint
output := object.union(
	input,
	{"handlers": {
		"preCreate": {"targetNames": resource_types},
		"preUpdate": {"targetNames": resource_types},
		"preDelete": {"targetNames": resource_types},
	}},
)
