resource "oci_identity_dynamic_group" "HeadNode_DG" {
  compartment_id = var.tenancy_ocid

  description   = "Group for Head Node in deployment ${local.Sp3_deploy_id}"
  matching_rule = "Any {Any {instance.id = '${local.Sp3Headnode_id}'}}"
  name          = "${local.Sp3_env_name}_HeadNode"
}

resource "oci_identity_policy" "HeadNode_Policy" {
  compartment_id = local.Sp3_cid

  description = "Policy for Head Node in deployment ${local.Sp3_deploy_id}"
  
  # Need to know what the correct permissions required are  <<CHANGE_ME>>
  
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.HeadNode_DG.name} to manage all-resources in compartment id ${local.Sp3_cid}",
  ]
  name = "${local.Sp3_env_name}_HeadNode"
}
