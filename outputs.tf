output "enable_managed_db" {
  description = "Whether Atlas resources are managed by this stack"
  value       = var.enable_managed_db
}

output "atlas_cluster_name" {
  description = "Atlas cluster name (empty when disabled)"
  value       = var.enable_managed_db ? mongodbatlas_advanced_cluster.this[0].name : ""
}

output "mongodb_uri_ssm_path" {
  description = "SSM parameter that stores the connection string"
  value       = var.enable_managed_db ? aws_ssm_parameter.mongodb_uri[0].name : ""
}
