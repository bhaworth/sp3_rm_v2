resource "oci_load_balancer_load_balancer" "sp3_loadbalancer" {
  compartment_id = local.Sp3_cid

  display_name = "${local.Sp3_env_name}-loadbalancer"

  ip_mode                    = "IPV4"
  is_private                 = "false"
  network_security_group_ids = [local.lb_nsg_id]

  shape = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = "20"
    minimum_bandwidth_in_mbps = "20"
  }
  subnet_ids = [
    local.Pubsn001_id,
  ]
}

locals {
  Sp3_lb_public_ip = lookup(oci_load_balancer_load_balancer.sp3_loadbalancer.ip_address_details[0], "ip_address")
  Sp3_lb_url = var.create_dns ? "https://${local.Sp3_env_name}.${local.Sp3_dns_suffix}" : format("http://%s", local.Sp3_lb_public_ip)
}
output "sp3_loadbalancer_url" {
  value = local.Sp3_lb_url
}
output "sp3_loadbalancer_public_ip" {
  value = local.Sp3_lb_public_ip
}

locals { Sp3_lb_id = oci_load_balancer_load_balancer.sp3_loadbalancer.id }

resource "oci_load_balancer_backend_set" "sp3_backendset_443" {
  health_checker {
    interval_ms         = "10000"
    port                = "443"
    protocol            = "TCP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_deploy_id}-backendset_443"
  policy           = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "be_443" {
  backendset_name  = oci_load_balancer_backend_set.sp3_backendset_443.name
  backup           = "false"
  drain            = "false"
  ip_address       = "10.0.1.2"
  load_balancer_id = local.Sp3_lb_id
  offline          = "false"
  port             = "443"
  weight           = "1"
}


resource "oci_load_balancer_listener" "sp3_loadbalancer_listener_443" {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "300"
  }
  default_backend_set_name = oci_load_balancer_backend_set.sp3_backendset_443.name
  hostname_names = [
  ]
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_deploy_id}-loadbalancer_listener_443"
  port             = "443"
  protocol         = "TCP"
  rule_set_names = [
  ]
}

resource "oci_load_balancer_backend_set" "sp3_backendset_80" {
  health_checker {
    interval_ms         = "10000"
    port                = "80"
    protocol            = "TCP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_deploy_id}-backendset_80"
  policy           = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "be_80" {
  backendset_name  = oci_load_balancer_backend_set.sp3_backendset_80.name
  backup           = "false"
  drain            = "false"
  ip_address       = "10.0.1.2"
  load_balancer_id = local.Sp3_lb_id
  offline          = "false"
  port             = "80"
  weight           = "1"
}


resource "oci_load_balancer_listener" "sp3_loadbalancer_listener_80" {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "300"
  }
  default_backend_set_name = oci_load_balancer_backend_set.sp3_backendset_80.name
  hostname_names = [
  ]
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_deploy_id}-loadbalancer_listener_80"
  port             = "80"
  protocol         = "TCP"
  rule_set_names = [
  ]
}

# resource "oci_load_balancer_rule_set" "url_redirect_port80" {
#   items {
#     action = "REDIRECT"
#     conditions {
#       attribute_name  = "PATH"
#       attribute_value = "/"
#       operator        = "FORCE_LONGEST_PREFIX_MATCH"
#     }
#     redirect_uri {
#       host     = "{host}"
#       path     = "/{path}"
#       port     = "443"
#       protocol = "https"
#       query    = "?{query}"
#     }
#     response_code = "301"
#   }
#   load_balancer_id = local.Sp3_lb_id
#   name             = "URLRedirect"
# } 

