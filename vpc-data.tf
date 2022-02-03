# Choose an existing VPC data source

# ------------------------------
# (1) Uncomment the following if using default VPC
# ------------------------------
# data "aws_vpc" "default" {
#   default = true
# }

# data "aws_subnets" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }

# locals {
#   vpc_id    = data.aws_vpc.default.id
#   subnet_id = data.aws_subnets.default.ids[0]
# }


# ------------------------------
# (2) Uncomment the following if VPC data is stored in S3. Check your vpc infra code.
# ------------------------------
# data "terraform_remote_state" "networking" {
#   backend = "s3"
#   config = {
#     bucket         = "{namespace}-{environment}-state-storage"
#     key            = "/path/to/vpc/terraform.tfstate"
#     dynamodb_table = "{namespace}-{environment}-lock-dynamo"
#     region         = "see AWS_REGION in .env"
#     profile        = "see AWS_PROFILE in .env"
#     encrypt        = true
#   }
# }
#
# locals {
#   vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
#   subnet_id = data.terraform_remote_state.networking.outputs.public_subnets[0]
# }


# ------------------------------
# (3) Uncomment the following if VPC data is in TF Cloud.
#    Check your vpc infra code or TF Cloud account.
# ------------------------------
# data "terraform_remote_state" "networking" {
#   backend = "remote"
#   config = {
#     organization = var.organization
#     workspaces = {
#       name = "networking-${var.environment}"
#     }
#   }
# }
#
# locals {
#   vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
#   subnet_id = data.terraform_remote_state.networking.outputs.public_subnets[0]
# }
