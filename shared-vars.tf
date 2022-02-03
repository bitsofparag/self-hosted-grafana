#=================================================
# Don't modify this - use .tfvars file or env vars
#=================================================
## Provider vars
variable "profile" {
  description = "AWS user authorized to manage deployments"
  type        = string
  default     = "foo"
}

variable "default_region" {
  description = "Default region, usually assigned on account creation."
  type        = string
  default     = "eu-central-1"
}

variable "organization" {
  type        = string
  default     = "acme"
  description = "The organization name where this workspace is created."
}

## Labels and tags
variable "project" {
  type        = string
  default     = "foo"
  description = "Project SHORT name or namespace used in labels name (e.g `acme`). Same as `project_namespace`"
}

variable "project_namespace" {
  type        = string
  default     = "foo"
  description = "Short project namespace (e.g `acme`) used in labels"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment (e.g. `dev` or `prod`). No 'stg' env for data-collection."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags, for e.g. {\"network\" = \"vpc\"}."
}

variable "AWS_ACCESS_KEY_ID" {
  type    = string
  default = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type    = string
  default = ""
}

variable "key_pair_name" {
  type    = string
  default = "foo_ec2"
}
