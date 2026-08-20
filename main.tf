terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.21"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  mongodb_uri = var.enable_managed_db ? replace(
    mongodbatlas_advanced_cluster.this[0].connection_strings[0].standard_srv,
    "mongodb+srv://",
    "mongodb+srv://${var.db_username}:${urlencode(var.db_password)}@",
  ) : ""

  mongodb_uri_with_db = var.enable_managed_db ? "${local.mongodb_uri}/${var.database_name}?retryWrites=true&w=majority" : ""
}
