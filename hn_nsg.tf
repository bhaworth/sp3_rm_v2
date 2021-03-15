# Network Security Group for the Head Node

# Allows Public and Private Network to mount NFS shares from Head Node

resource "oci_core_network_security_group" "headnode_nsg" {
  display_name   = "${local.Sp3_env_name}-hn-nsg"
  vcn_id         = local.Sp3_vcn_id
  compartment_id = local.Sp3_cid
}

locals {
  hn_nsg_id = oci_core_network_security_group.headnode_nsg.id
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule1" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "6"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      min = "111"
      max = "111"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule2" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "6"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      min = "2000"
      max = "2001"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule3" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "6"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  tcp_options {
    destination_port_range {
      min = "2049"
      max = "2049"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule4" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "17"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  udp_options {
    destination_port_range {
      min = "111"
      max = "111"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule5" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "17"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  udp_options {
    destination_port_range {
      min = "2000"
      max = "2000"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule6" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "17"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  udp_options {
    destination_port_range {
      min = "2002"
      max = "2002"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "hn-nsg-rule7" {
  network_security_group_id = local.hn_nsg_id

  direction   = "INGRESS"
  protocol    = "17"
  source      = "10.0.0.0/23"
  source_type = "CIDR_BLOCK"
  stateless   = false
  udp_options {
    destination_port_range {
      min = "2049"
      max = "2049"
    }
  }
}
