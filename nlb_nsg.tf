# Network Security Group for the Load Balancer

# Allow port 80 and 443 in to the load balancer

resource "oci_core_network_security_group" "nlb_nsg" {
  display_name   = "${local.Sp3_env_name}-nlb-nsg"
  vcn_id         = local.Sp3_vcn_id
  compartment_id = local.Sp3_cid
}

locals {
  nlb_nsg_id = oci_core_network_security_group.nlb_nsg.id
}

resource "oci_core_network_security_group_security_rule" "nlb-nsg-rule1" {
  network_security_group_id = local.nlb_nsg_id

  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false
  description = "TCP/80 (HTTP) for Inbound HTTP"
  tcp_options {
    destination_port_range {
      min = "80"
      max = "80"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nlb-nsg-rule2" {
  network_security_group_id = local.nlb_nsg_id

  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  stateless   = false
  description = "TCP/443 (HTTPS) for Inbound HTTPS"
  tcp_options {
    destination_port_range {
      min = "443"
      max = "443"
    }
  }
}
