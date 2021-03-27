resource "oci_identity_dynamic_group" "HeadNode_DG" {
  compartment_id = var.tenancy_ocid

  description   = "Group for Head Node in deployment ${local.Sp3_env_name}"
  matching_rule = "Any {Any {instance.id = '${local.Sp3Headnode_id}'}}"
  name          = "${local.Sp3_env_name}_HeadNode"
}

resource "oci_identity_policy" "HeadNode_Comp_Policy" {
  compartment_id = var.compartment_ocid

  description = "Policy for Head Node in deployment ${local.Sp3_env_name}"

  # Need to know what the correct permissions required are  <<CHANGE_ME>>

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to manage all-resources in compartment id ${var.compartment_ocid}",
  ]
  name = "${local.Sp3_env_name}_HeadNode_Comp"
}

resource "oci_identity_policy" "HeadNode_Secrets_Policy" {
  compartment_id = local.Sp3dev_vault_comp_id

  description = "Policy for Head Node secrets in deployment ${local.Sp3_env_name}"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to use secret-family in compartment id ${local.Sp3dev_vault_comp_id}",
  ]
  name = "${local.Sp3_env_name}_HeadNode_Secrets"
}

resource "oci_identity_policy" "HeadNode_Sandbox_Object_Policy" {
  compartment_id = local.Sp3dev_sandox_cid

  description = "Policy for Head Node secrets in deployment ${local.Sp3_env_name}"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to read objects in compartment id ${local.Sp3dev_sandox_cid}",
  ]
  name = "${local.Sp3_env_name}_HeadNode_Object"
}

resource "oci_identity_compartment" "sp3_child_comp" {
  # If 'create child compartment' is true, create a new compartment else don't
  count = var.create_child_comp ? 1 : 0
  enable_delete  = true
  compartment_id = var.compartment_ocid
  description    = "Compartment for the SP3 Cluster with Deployment ID: ${local.Sp3_env_name}"
  name           = "deployment_${local.Sp3_env_name}"
}

locals { 
  # If 'create child compartment' is true, use the new compartment otherwise use the parent
  Sp3_cid = var.create_child_comp ? oci_identity_compartment.sp3_child_comp[0].id : var.compartment_ocid
}