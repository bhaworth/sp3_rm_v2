# Bastion as a Service

resource "oci_bastion_bastion" "sp3_bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = local.Sp3_cid
  target_subnet_id             = local.Privsn001_id
  name                         = "${local.Sp3_deploy_id}Bastion"
  client_cidr_block_allow_list = ["0.0.0.0/0"]
}

resource "oci_bastion_session" "sp3_hn_session" {
  #Required
  bastion_id = oci_bastion_bastion.sp3_bastion.id
  key_details {
    public_key_content = local.Sp3_ssh_key
  }
  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = local.Sp3Headnode_id
    target_resource_operating_system_user_name = "ubuntu"
    target_resource_private_ip_address         = oci_core_instance.Sp3Headnode.private_ip
  }

  display_name           = local.Sp3_env_name
  key_type               = "PUB"
  session_ttl_in_seconds = 3600
  depends_on = [
    time_sleep.wait_headnode_plugins
  ]
}

output "bastion_connect_string" {
  value = oci_bastion_session.sp3_hn_session.ssh_metadata["command"]
}
