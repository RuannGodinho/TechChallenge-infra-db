check "atlas_credentials_when_enabled" {
  assert {
    condition = !var.enable_managed_db || (
      var.atlas_public_key != "" &&
      var.atlas_private_key != "" &&
      var.atlas_org_id != "" &&
      var.db_password != ""
    )
    error_message = "enable_managed_db=true requires atlas_public_key, atlas_private_key, atlas_org_id, and db_password."
  }
}
