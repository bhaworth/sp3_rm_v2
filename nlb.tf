resource "oci_network_load_balancer_network_load_balancer" "sp3_nlb" {
  compartment_id = local.Sp3_cid

  display_name = "${local.Sp3_env_name}-nlb"

  is_private                 = "false"
  network_security_group_ids = [local.nlb_nsg_id]

  subnet_id = local.Pubsn001_id
}

locals {
  Sp3_nlb_public_ip = lookup(oci_network_load_balancer_network_load_balancer.sp3_nlb.ip_addresses[0], "ip_address")
  Sp3_nlb_url       = var.create_dns ? "https://${local.Sp3_env_name}.oci.sp3dev.ml" : format("http://%s", local.Sp3_nlb_public_ip)
}
output "sp3_loadbalancer_url" {
  value = local.Sp3_nlb_url
}
output "sp3_loadbalancer_public_ip" {
  value = local.Sp3_nlb_public_ip
}

locals { Sp3_nlb_id = oci_network_load_balancer_network_load_balancer.sp3_nlb.id }

resource "oci_network_load_balancer_backend_set" "sp3_backendset_443" {
  health_checker {
    interval_in_millis  = "10000"
    port                = "443"
    protocol            = "TCP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  network_load_balancer_id = local.Sp3_nlb_id
  name                     = "${local.Sp3_deploy_id}-backendset_443"
  policy                   = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_backend" "be_443" {
  backend_set_name         = oci_network_load_balancer_backend_set.sp3_backendset_443.name
  backup                   = "false"
  drain                    = "false"
  ip_address               = "10.0.1.2"
  network_load_balancer_id = local.Sp3_nlb_id
  offline                  = "false"
  port                     = "443"
  weight                   = "1"
}


resource "oci_network_load_balancer_listener" "sp3_loadbalancer_listener_443" {
  default_backend_set_name = oci_network_load_balancer_backend_set.sp3_backendset_443.name
  network_load_balancer_id = local.Sp3_nlb_id
  name                     = "${local.Sp3_deploy_id}-nlb_listener_443"
  port                     = "443"
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_backend_set" "sp3_backendset_80" {
  health_checker {
    interval_in_millis  = "10000"
    port                = "80"
    protocol            = "TCP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  network_load_balancer_id = local.Sp3_nlb_id
  name                     = "${local.Sp3_deploy_id}-backendset_80"
  policy                   = "FIVE_TUPLE"
}

resource "oci_network_load_balancer_backend" "be_80" {
  backend_set_name         = oci_network_load_balancer_backend_set.sp3_backendset_80.name
  backup                   = "false"
  drain                    = "false"
  ip_address               = "10.0.1.2"
  network_load_balancer_id = local.Sp3_nlb_id
  offline                  = "false"
  port                     = "80"
  weight                   = "1"
}


resource "oci_network_load_balancer_listener" "sp3_loadbalancer_listener_80" {
  default_backend_set_name = oci_network_load_balancer_backend_set.sp3_backendset_80.name
  network_load_balancer_id = local.Sp3_nlb_id
  name                     = "${local.Sp3_deploy_id}-nlb_listener_80"
  port                     = "80"
  protocol                 = "TCP"
}


