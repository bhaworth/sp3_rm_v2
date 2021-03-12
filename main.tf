
# ------ Retrieve Regional / Cloud Data
# -------- Get a list of Availability Domains
data "oci_identity_availability_domains" "AvailabilityDomains" {
    compartment_id = var.compartment_ocid
}
data "template_file" "AvailabilityDomainNames" {
    count    = length(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains)
    template = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains[count.index]["name"]
}
# -------- Get a list of Fault Domains
data "oci_identity_fault_domains" "FaultDomainsAD1" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 0)["name"]
    compartment_id = var.compartment_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD2" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 1)["name"]
    compartment_id = var.compartment_ocid
}
data "oci_identity_fault_domains" "FaultDomainsAD3" {
    availability_domain = element(data.oci_identity_availability_domains.AvailabilityDomains.availability_domains, 2)["name"]
    compartment_id = var.compartment_ocid
}

# ------ Get List Images
data "oci_core_images" "InstanceImages" {
    compartment_id           = var.compartment_ocid
}

# ------ Provider
provider "oci" {
    region           = var.region
}

locals {
    Sp3_id              = var.compartment_ocid
    Sp3_ssh_key         = var.ssh_pub_key
    Sp3_bastion_shape   = var.bastion_shape
    Sp3_headnode_shape  = var.headnode_shape
}

output "Sp3Id" {
    value = local.Sp3_id
}

# ------ Create Virtual Cloud Network
resource "oci_core_vcn" "Sp3_Sandbox" {
    # Required
    compartment_id = local.Sp3_id
    cidr_block     = "10.0.0.0/16"
    # Optional
    dns_label      = "sp3sandbox"
    display_name   = "sp3-sandbox"
}

locals {
    Sp3_Sandbox_id                       = oci_core_vcn.Sp3_Sandbox.id
    Sp3_Sandbox_dhcp_options_id          = oci_core_vcn.Sp3_Sandbox.default_dhcp_options_id
    Sp3_Sandbox_domain_name              = oci_core_vcn.Sp3_Sandbox.vcn_domain_name
    Sp3_Sandbox_default_dhcp_options_id  = oci_core_vcn.Sp3_Sandbox.default_dhcp_options_id
    Sp3_Sandbox_default_security_list_id = oci_core_vcn.Sp3_Sandbox.default_security_list_id
    Sp3_Sandbox_default_route_table_id   = oci_core_vcn.Sp3_Sandbox.default_route_table_id
}

# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Sp3_Igw" {
    # Required
    compartment_id = local.Sp3_id
    vcn_id         = local.Sp3_Sandbox_id
    # Optional
    enabled        = true
    display_name   = "sp3-igw"
}

locals {
    Sp3_Igw_id = oci_core_internet_gateway.Sp3_Igw.id
}

# ------ Create NAT Gateway
resource "oci_core_nat_gateway" "Sp3Ng001" {
    # Required
    compartment_id = local.Sp3_id
    vcn_id         = local.Sp3_Sandbox_id
    # Optional
    display_name   = "sp3ng001"
    block_traffic  = false
}

locals {
    Sp3Ng001_id = oci_core_nat_gateway.Sp3Ng001.id
}

# ------ Create Security List
# ------- Update VCN Default Security List
resource "oci_core_default_security_list" "Pubsl001" {
    # Required
    manage_default_resource_id = local.Sp3_Sandbox_default_security_list_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "0.0.0.0/0"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "22"
            max = "22"
        }
    }
    # Optional
    display_name   = "pubsl001"
}

locals {
    Pubsl001_id = oci_core_default_security_list.Pubsl001.id
}


# ------ Create Security List
resource "oci_core_security_list" "Privsl001" {
    # Required
    compartment_id = local.Sp3_id
    vcn_id         = local.Sp3_Sandbox_id
    egress_security_rules {
        # Required
        protocol    = "all"
        destination = "0.0.0.0/0"
        # Optional
        destination_type  = "CIDR_BLOCK"
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "22"
            max = "22"
        }
    }
    # Optional
    display_name   = "privsl001"
}

locals {
    Privsl001_id = oci_core_security_list.Privsl001.id
}


# ------ Create Route Table
# ------- Update VCN Default Route Table
resource "oci_core_default_route_table" "Pubrt001" {
    # Required
    manage_default_resource_id = local.Sp3_Sandbox_default_route_table_id
    route_rules    {
        destination_type  = "CIDR_BLOCK"
        destination       = "0.0.0.0/0"
        network_entity_id = local.Sp3_Igw_id
        description       = ""
    }
    # Optional
    display_name   = "pubrt001"
}

locals {
    Pubrt001_id = oci_core_default_route_table.Pubrt001.id
    }


# ------ Create Route Table
resource "oci_core_route_table" "Privrt001" {
    # Required
    compartment_id = local.Sp3_id
    vcn_id         = local.Sp3_Sandbox_id
    route_rules    {
        destination_type  = "CIDR_BLOCK"
        destination       = "0.0.0.0/0"
        network_entity_id = local.Sp3Ng001_id
        description       = ""
    }
    # Optional
    display_name   = "privrt001"
}

locals {
    Privrt001_id = oci_core_route_table.Privrt001.id
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Pubsn001" {
    # Required
    compartment_id             = local.Sp3_id
    vcn_id                     = local.Sp3_Sandbox_id
    cidr_block                 = "10.0.0.0/24"
    # Optional
    display_name               = "pubsn001"
    dns_label                  = "pubsn01"
    security_list_ids          = [local.Pubsl001_id]
    route_table_id             = local.Pubrt001_id
    dhcp_options_id            = local.Sp3_Sandbox_dhcp_options_id
    prohibit_public_ip_on_vnic = false
}

locals {
    Pubsn001_id              = oci_core_subnet.Pubsn001.id
    Pubsn001_domain_name     = oci_core_subnet.Pubsn001.subnet_domain_name
}

# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Privsn001" {
    # Required
    compartment_id             = local.Sp3_id
    vcn_id                     = local.Sp3_Sandbox_id
    cidr_block                 = "10.0.1.0/24"
    # Optional
    display_name               = "privsn001"
    dns_label                  = "privsn001"
    security_list_ids          = [local.Privsl001_id]
    route_table_id             = local.Privrt001_id
    dhcp_options_id            = local.Sp3_Sandbox_dhcp_options_id
    prohibit_public_ip_on_vnic = true
}

locals {
    Privsn001_id              = oci_core_subnet.Privsn001.id
    Privsn001_domain_name     = oci_core_subnet.Privsn001.subnet_domain_name
}

# ------ Get List Images
data "oci_core_images" "Sp3BastionImages" {
    compartment_id           = var.compartment_ocid
    operating_system         = "Canonical Ubuntu"
    operating_system_version = "18.04"
    shape                    = local.Sp3_bastion_shape
}

# ------ Create Instance
resource "oci_core_instance" "Sp3Bastion" {
    # Required
    compartment_id      = local.Sp3_id
    shape               = local.Sp3_bastion_shape
    # Optional
    display_name        = "sp3bastion"
    availability_domain = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains["1" - 1]["name"]
    agent_config {
        # Optional
    }
    create_vnic_details {
        # Required
        subnet_id        = local.Pubsn001_id
        # Optional
        assign_public_ip = true
        display_name     = "sp3bastion vnic 00"
        hostname_label   = "sp3bastion"
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
        source_id               = data.oci_core_images.Sp3BastionImages.images[0]["id"]
        source_type             = "image"
        # Optional
        boot_volume_size_in_gbs = "50"
#        kms_key_id              = 
    }
    preserve_boot_volume = false
}

locals {
    Sp3Bastion_id            = oci_core_instance.Sp3Bastion.id
    Sp3Bastion_public_ip     = oci_core_instance.Sp3Bastion.public_ip
    Sp3Bastion_private_ip    = oci_core_instance.Sp3Bastion.private_ip
}

output "sp3bastionPublicIP" {
    value = local.Sp3Bastion_public_ip
}

output "sp3bastionPrivateIP" {
    value = local.Sp3Bastion_private_ip
}

# ------ Create Block Storage Attachments

# ------ Create VNic Attachments


# ------ Get List Images
data "oci_core_images" "Sp3HeadnodeImages" {
    compartment_id           = var.compartment_ocid
    operating_system         = "Canonical Ubuntu"
    operating_system_version = "18.04"
    shape                    = local.Sp3_headnode_shape
}

# ------ Create Instance
resource "oci_core_instance" "Sp3Headnode" {
    # Required
    compartment_id      = local.Sp3_id
    shape               = local.Sp3_headnode_shape
    # Optional
    display_name        = "sp3headnode"
    availability_domain = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains["1" - 1]["name"]
    agent_config {
        # Optional
    }
    create_vnic_details {
        # Required
        subnet_id        = local.Privsn001_id
        # Optional
        assign_public_ip = false
        display_name     = "sp3headnode vnic 00"
        hostname_label   = "sp3headnode"
        skip_source_dest_check = "false"
    }
#    extended_metadata {
#        some_string = "stringA"
#        nested_object = "{\"some_string\": \"stringB\", \"object\": {\"some_string\": \"stringC\"}}"
#    }
    metadata = {
        ssh_authorized_keys = local.Sp3_ssh_key
        user_data           = base64encode(file("./userdata/bootstrap.sh"))
    }
    
    source_details {
        # Required
        source_id               = data.oci_core_images.Sp3HeadnodeImages.images[0]["id"]
        source_type             = "image"
        # Optional
        boot_volume_size_in_gbs = "120"
#        kms_key_id              = 
    }
    preserve_boot_volume = false
}

locals {
    Sp3Headnode_id            = oci_core_instance.Sp3Headnode.id
    Sp3Headnode_public_ip     = oci_core_instance.Sp3Headnode.public_ip
    Sp3Headnode_private_ip    = oci_core_instance.Sp3Headnode.private_ip
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
    compartment_id = local.Sp3_id
    availability_domain = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains["1" - 1]["name"]
    # Optional
    display_name   = "data"
    size_in_gbs    = "1024"
    vpus_per_gb    = "10"
}

locals {
    Data_id = oci_core_volume.Data.id
}

# ------ Create Block Storage Volume
resource "oci_core_volume" "Work" {
    # Required
    compartment_id = local.Sp3_id
    availability_domain = data.oci_identity_availability_domains.AvailabilityDomains.availability_domains["1" - 1]["name"]
    # Optional
    display_name   = "work"
    size_in_gbs    = "1024"
    vpus_per_gb    = "10"
}

locals {
    Work_id = oci_core_volume.Work.id
}

# ------ Create Block Storage Attachments
resource oci_core_volume_attachment "Sp3HeadnodeDataVolumeAttachment" {
  attachment_type                     = "paravirtualized"
  device                              = "/dev/oracleoci/oraclevdb"
  display_name                        = "Sp3HeadnodeDataVolumeAttachment"
  instance_id                         = local.Sp3Headnode_id
  is_pv_encryption_in_transit_enabled = "false"
  is_read_only                        = "false"
  #is_shareable = <<Optional value not found in discovery>>
  #use_chap = <<Optional value not found in discovery>>
  volume_id = local.Data_id
}
resource oci_core_volume_attachment "Sp3HeadnodeWorkVolumeAttachment" {
  attachment_type                     = "paravirtualized"
  device                              = "/dev/oracleoci/oraclevdc"
  display_name                        = "Sp3HeadnodeDataVolumeAttachment"
  instance_id                         = local.Sp3Headnode_id
  is_pv_encryption_in_transit_enabled = "false"
  is_read_only                        = "false"
  #is_shareable = <<Optional value not found in discovery>>
  #use_chap = <<Optional value not found in discovery>>
  volume_id = local.Work_id
}

