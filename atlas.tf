resource "mongodbatlas_project" "this" {
  count  = var.enable_managed_db ? 1 : 0
  name   = var.atlas_project_name
  org_id = var.atlas_org_id
}

resource "mongodbatlas_advanced_cluster" "this" {
  count = var.enable_managed_db ? 1 : 0

  project_id   = mongodbatlas_project.this[0].id
  name         = var.atlas_cluster_name
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      electable_specs {
        instance_size = "M0"
      }
      provider_name         = "TENANT"
      backing_provider_name = "AWS"
      region_name           = var.atlas_region
      priority              = 7
    }
  }
}

resource "mongodbatlas_database_user" "this" {
  count = var.enable_managed_db ? 1 : 0

  username           = var.db_username
  password           = var.db_password
  project_id         = mongodbatlas_project.this[0].id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }
}

resource "mongodbatlas_project_ip_access_list" "this" {
  count = var.enable_managed_db ? 1 : 0

  project_id = mongodbatlas_project.this[0].id
  cidr_block = var.atlas_ip_access_cidr
  comment    = "Tech Challenge lab access"
}
