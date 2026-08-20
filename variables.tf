variable "aws_region" {
  description = "AWS region for SSM parameters"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project tag"
  type        = string
  default     = "techchallenge-fiap"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "lab"
}

variable "enable_managed_db" {
  description = "Create MongoDB Atlas M0 and publish the URI to SSM. Keep false until cutover from in-cluster Mongo."
  type        = bool
  default     = false
}

variable "atlas_public_key" {
  description = "MongoDB Atlas API public key"
  type        = string
  default     = ""
}

variable "atlas_private_key" {
  description = "MongoDB Atlas API private key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "atlas_org_id" {
  description = "MongoDB Atlas organization ID"
  type        = string
  default     = ""
}

variable "atlas_project_name" {
  description = "Atlas project name"
  type        = string
  default     = "techchallenge-fiap"
}

variable "atlas_cluster_name" {
  description = "Atlas cluster name (M0 free tier)"
  type        = string
  default     = "techchallenge"
}

variable "atlas_region" {
  description = "Atlas AWS region name (underscored)"
  type        = string
  default     = "US_EAST_1"
}

variable "db_username" {
  description = "Database user created in Atlas"
  type        = string
  default     = "techchallenge"
}

variable "db_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "database_name" {
  description = "MongoDB database name (matches the in-cluster app)"
  type        = string
  default     = "Node-Fiap"
}

variable "atlas_ip_access_cidr" {
  description = "CIDR allowed to reach Atlas. 0.0.0.0/0 is acceptable only for lab."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssm_prefix" {
  description = "SSM prefix shared with the app CD"
  type        = string
  default     = "/techchallenge"
}
