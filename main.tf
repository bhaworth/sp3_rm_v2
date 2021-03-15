
# ------ Get List Images
data "oci_core_images" "InstanceImages" {
  compartment_id = var.compartment_ocid
}

# ------ Provider
provider "oci" {
  region = var.region
}

locals {
  Sp3_env_name       = "${var.name_prefix}-${var.env_name}"
  Sp3_cid            = var.compartment_ocid
  Sp3_ssh_key        = var.ssh_pub_key
  Sp3_bastion_shape  = var.bastion_shape
  Sp3_bastion_image  = var.bastion_image
  Sp3_headnode_shape = var.headnode_shape
  Sp3_headnode_image = var.headnode_image
  Sp3_ad             = var.ad
}

# ------ Get List Images
#data "oci_core_images" "Sp3BastionImages" {
#compartment_id           = var.compartment_ocid
#operating_system         = "Canonical Ubuntu"
#operating_system_version = "18.04"
#shape                    = local.Sp3_bastion_shape
#}

# ------ Create Instance
resource "oci_core_instance" "Sp3Bastion" {
  # Required
  compartment_id = local.Sp3_cid
  shape          = local.Sp3_bastion_shape
  # Optional
  display_name        = "${local.Sp3_env_name}-bastion"
  availability_domain = local.Sp3_ad
  agent_config {
    # Optional
  }
  create_vnic_details {
    # Required
    subnet_id = local.Pubsn001_id
    # Optional
    assign_public_ip       = true
    display_name           = "${local.Sp3_vcn_name}-bastion vnic 00"
    hostname_label         = "${local.Sp3_vcn_name}-bastion"
    skip_source_dest_check = "false"
  }
  #    extended_metadata {
  #        some_string = "stringA"
  #        nested_object = "{\"some_string\": \"stringB\", \"object\": {\"some_string\": \"stringC\"}}"
  #    }
  metadata = {
    ssh_authorized_keys = local.Sp3_ssh_key
    user_data           = base64encode("")
  }

  source_details {
    # Required
    #source_id               = data.oci_core_images.Sp3BastionImages.images[0]["id"]
    source_id   = local.Sp3_bastion_image
    source_type = "image"
    # Optional
    boot_volume_size_in_gbs = "50"
    #        kms_key_id              = 
  }
  preserve_boot_volume = false
}

locals {
  Sp3Bastion_id         = oci_core_instance.Sp3Bastion.id
  Sp3Bastion_public_ip  = oci_core_instance.Sp3Bastion.public_ip
  Sp3Bastion_private_ip = oci_core_instance.Sp3Bastion.private_ip
}

output "sp3bastionPublicIP" {
  value = local.Sp3Bastion_public_ip
}

output "sp3bastionPrivateIP" {
  value = local.Sp3Bastion_private_ip
}

# ------ Get List Images
#data "oci_core_images" "Sp3HeadnodeImages" {
#    compartment_id           = var.compartment_ocid
#    operating_system         = "Canonical Ubuntu"
#    operating_system_version = "18.04"
#    shape                    = local.Sp3_headnode_shape
#}

# ------ Create Instance
resource "oci_core_instance" "Sp3Headnode" {
  # Required
  compartment_id = local.Sp3_cid
  shape          = local.Sp3_headnode_shape
  # Optional
  display_name        = "${local.Sp3_env_name}-headnode"
  availability_domain = local.Sp3_ad
  agent_config {
    # Optional
  }
  create_vnic_details {
    # Required
    subnet_id = local.Privsn001_id
    # Optional
    assign_public_ip       = false
    display_name           = "${local.Sp3_env_name}headnode vnic 00"
    hostname_label         = "${local.Sp3_env_name}headnode"
    skip_source_dest_check = "false"
    nsg_ids                = [local.hn_nsg_id]
  }
  metadata = {
    ssh_authorized_keys = local.Sp3_ssh_key
    user_data           = base64encode(file("./userdata/bootstrap.sh"))
  }

  source_details {
    # Required
    #source_id               = data.oci_core_images.Sp3HeadnodeImages.images[0]["id"]
    source_id   = local.Sp3_headnode_image
    source_type = "image"
    # Optional
    boot_volume_size_in_gbs = var.hn_boot_size
    #        kms_key_id              = 
  }
  preserve_boot_volume = false
}

locals {
  Sp3Headnode_id         = oci_core_instance.Sp3Headnode.id
  Sp3Headnode_public_ip  = oci_core_instance.Sp3Headnode.public_ip
  Sp3Headnode_private_ip = oci_core_instance.Sp3Headnode.private_ip
}

output "sp3headnodePublicIP" {
  value = local.Sp3Headnode_public_ip
}

output "sp3headnodePrivateIP" {
  value = local.Sp3Headnode_private_ip
}

# ------ Create Block Storage Volume
resource "oci_core_volume" "Data" {
  # Required
  compartment_id      = local.Sp3_cid
  availability_domain = local.Sp3_ad
  # Optional
  display_name = "${local.Sp3_env_name}_data"
  size_in_gbs  = var.hn_data_size
  vpus_per_gb  = "10"
}

locals {
  Data_id = oci_core_volume.Data.id
}

# ------ Create Block Storage Volume
resource "oci_core_volume" "Work" {
  # Required
  compartment_id      = local.Sp3_cid
  availability_domain = local.Sp3_ad
  # Optional
  display_name = "${local.Sp3_env_name}_work"
  size_in_gbs  = var.hn_work_size
  vpus_per_gb  = "10"
}

locals {
  Work_id = oci_core_volume.Work.id
}

# ------ Create Block Storage Attachments
resource "oci_core_volume_attachment" "Sp3HeadnodeDataVolumeAttachment" {
  attachment_type                     = "paravirtualized"
  device                              = "/dev/oracleoci/oraclevdb"
  display_name                        = "${local.Sp3_env_name}-HeadnodeDataVolumeAttachment"
  instance_id                         = local.Sp3Headnode_id
  is_pv_encryption_in_transit_enabled = "false"
  is_read_only                        = "false"
  #is_shareable = <<Optional value not found in discovery>>
  #use_chap = <<Optional value not found in discovery>>
  volume_id = local.Data_id
}
resource "oci_core_volume_attachment" "Sp3HeadnodeWorkVolumeAttachment" {
  attachment_type                     = "paravirtualized"
  device                              = "/dev/oracleoci/oraclevdc"
  display_name                        = "${local.Sp3_env_name}-HeadnodeDataVolumeAttachment"
  instance_id                         = local.Sp3Headnode_id
  is_pv_encryption_in_transit_enabled = "false"
  is_read_only                        = "false"
  #is_shareable = <<Optional value not found in discovery>>
  #use_chap = <<Optional value not found in discovery>>
  volume_id = local.Work_id
}

