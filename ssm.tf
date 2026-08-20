resource "aws_ssm_parameter" "mongodb_uri" {
  count = var.enable_managed_db ? 1 : 0

  name        = "${var.ssm_prefix}/db/mongodb_uri"
  description = "Managed MongoDB connection string for the Tech Challenge API"
  type        = "SecureString"
  value       = local.mongodb_uri_with_db
  tags        = local.common_tags
}
