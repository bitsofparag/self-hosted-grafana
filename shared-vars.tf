#===============================================
# Shared vars
#===============================================
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
  default     = "foo"
  description = "The organization name where this workspace is created."
}

## Labels and tags
variable "project" {
  type        = string
  default     = "foo"
  description = "Project name (e.g `concr`)"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `production`, `testing`, `staging`)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags, for e.g. {\"network\" = \"vpc\"}."
}
