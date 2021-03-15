locals {
    Sp3_vcn_name                         = "${var.name_prefix}_${var.env_name}"
    Sp3_Sandbox_id                       = oci_core_vcn.Sp3_Sandbox.id
    Sp3_Sandbox_dhcp_options_id          = oci_core_vcn.Sp3_Sandbox.default_dhcp_options_id
    Sp3_Sandbox_domain_name              = oci_core_vcn.Sp3_Sandbox.vcn_domain_name
    Sp3_Sandbox_default_dhcp_options_id  = oci_core_vcn.Sp3_Sandbox.default_dhcp_options_id
    Sp3_Sandbox_default_security_list_id = oci_core_vcn.Sp3_Sandbox.default_security_list_id
    Sp3_Sandbox_default_route_table_id   = oci_core_vcn.Sp3_Sandbox.default_route_table_id
}

# ------ Create Virtual Cloud Network
resource "oci_core_vcn" "Sp3_Sandbox" {
    # Required
    compartment_id = local.Sp3_cid
    cidr_block     = "10.0.0.0/16"
    # Optional
    dns_label      = "${var.name+prefix}${var.name}"
    display_name   = locals.Sp3_vcn_name
}

# ------ Create Internet Gateway
resource "oci_core_internet_gateway" "Sp3_Igw" {
    # Required
    compartment_id = local.Sp3_cid
    vcn_id         = local.Sp3_Sandbox_id
    # Optional
    enabled        = true
    display_name   = "${local.Sp3_vcn_name}-igw"
}

locals {
    Sp3_Igw_id = oci_core_internet_gateway.Sp3_Igw.id
}

# ------ Create NAT Gateway
resource "oci_core_nat_gateway" "Sp3Ng001" {
    # Required
    compartment_id = local.Sp3_cid
    vcn_id         = local.Sp3_Sandbox_id
    # Optional
    display_name   = "${local.Sp3_vcn_name}-ngw"
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
    display_name   = "${local.Sp3_vcn_name}-pubsl001"
}

locals {
    Pubsl001_id = oci_core_default_security_list.Pubsl001.id
}


# ------ Create Security List
resource "oci_core_security_list" "Privsl001" {
    # Required
    compartment_id = local.Sp3_cid
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
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "111"
            max = "111"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "2000"
            max = "2001"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "6"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        tcp_options {
            min = "2049"
            max = "2049"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "17"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        udp_options {
            min = "111"
            max = "111"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "17"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        udp_options {
            min = "2000"
            max = "2000"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "17"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        udp_options {
            min = "2002"
            max = "2002"
        }
    }
    ingress_security_rules {
        # Required
        protocol    = "17"
        source      = "10.0.0.0/16"
        # Optional
        source_type  = "CIDR_BLOCK"
        udp_options {
            min = "2049"
            max = "2049"
        }
    }
    # Optional
    display_name   = "${local.Sp3_vcn_name}-privsl001"
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
    display_name   = "${local.Sp3_vcn_name}-pubrt001"
}

locals {
    Pubrt001_id = oci_core_default_route_table.Pubrt001.id
    }


# ------ Create Route Table
resource "oci_core_route_table" "Privrt001" {
    # Required
    compartment_id = local.Sp3_cid
    vcn_id         = local.Sp3_Sandbox_id
    route_rules    {
        destination_type  = "CIDR_BLOCK"
        destination       = "0.0.0.0/0"
        network_entity_id = local.Sp3Ng001_id
        description       = ""
    }
    # Optional
    display_name   = "${local.Sp3_vcn_name}-privrt001"
}

locals {
    Privrt001_id = oci_core_route_table.Privrt001.id
}


# ------ Create Subnet
# ---- Create Public Subnet
resource "oci_core_subnet" "Pubsn001" {
    # Required
    compartment_id             = local.Sp3_cid
    vcn_id                     = local.Sp3_Sandbox_id
    cidr_block                 = "10.0.0.0/24"
    # Optional
    display_name               = "${local.Sp3_vcn_name}-pubsn001"
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
    compartment_id             = local.Sp3_cid
    vcn_id                     = local.Sp3_Sandbox_id
    cidr_block                 = "10.0.1.0/24"
    # Optional
    display_name               = "${local.Sp3_vcn_name}-privsn001"
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