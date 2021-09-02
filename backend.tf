# Choose a backend:

# ------------------------------
# 1. Uncomment the following if using local state
# ------------------------------
# terraform {
#   backend "local" {
#     path = "./grafana.tfstate"
#   }
# }


# ------------------------------
# 2. Uncomment the following if using S3 for state
# ------------------------------
# terraform {
#   backend "s3" {
#     bucket         = "{namespace}-{environment}-state-storage"
#     key            = "grafana/terraform.tfstate"
#     dynamodb_table = "{namespace}-{environment}-lock-dynamo"
#     region         = "see AWS_REGION in .env"
#     profile        = "see AWS_PROFILE in .env"
#     encrypt        = true
#   }
# }


# ------------------------------
# 3. Uncomment the following if using TF Cloud and set "organization"
# ------------------------------
# terraform {
#   backend "remote" {
#     organization = "see TFC_ORG_NAME in .env"
#     workspaces {
#       prefix = "grafana-"
#     }
#   }
# }
