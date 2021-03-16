resource oci_load_balancer_load_balancer sp3_loadbalancer {
  compartment_id = local.Sp3_cid
  
  display_name = "${local.Sp3_env_name}-loadbalancer"
  
  ip_mode    = "IPV4"
  is_private = "false"
  network_security_group_ids = [local.lb_nsg_id]

  shape = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = "10"
    minimum_bandwidth_in_mbps = "10"
  }
  subnet_ids = [
    local.Pubsn001_id,
  ]
}

output "sp3_loadbalancer_public_ip" {
  value = [oci_load_balancer.lb1.ip_address_details]
}

locals {Sp3_lb_id = oci_load_balancer_load_balancer.sp3_loadbalancer.id }

resource oci_load_balancer_certificate sp3_loadbalancer_certificate_1 {
  certificate_name = "${local.Sp3_env_name}-lbcert1"
  load_balancer_id = local.Sp3_lb_id
  public_certificate = "-----BEGIN CERTIFICATE-----\nMIIFMTCCBBmgAwIBAgISA+duP67JoGYzC9fYCk4fqEqVMA0GCSqGSIb3DQEBCwUA\nMDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD\nEwJSMzAeFw0yMTAyMjYxNDUyNThaFw0yMTA1MjcxNDUyNThaMBgxFjAUBgNVBAMT\nDW94Zm9yZGZ1bi5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCc\nk3Unk5+2+B1If3a2MjQEs5qYfvjtYBiQ/GUZd+KHBP7rp52RiAglPQUfuRmEMCwy\nqmBwRE8j9i6MYcN+tpi3xPp+HrL6HbD/XOoR19xdSIn21Vlq0ZfOZIaSGguOemXI\n7ZcDdBJDdNEJoOwNcFyn0IiOlY+5ffZSQSUgoI64hlUBJ8ADq/FAthggsHnWf+th\nyer03YZ7nq6tu0/wFv6GiIL6XnOD7s/SPPDATcVNTohfq/uVJ11LeRBNO+oELIdB\nbdYWDi39PFOEUVyUg6O8lR+8Law68Dmkm6LjehihO65XoLPn0rYyjOgm6Xn07VTf\n+2uHLymwrcPr4Kr+FjR/AgMBAAGjggJZMIICVTAOBgNVHQ8BAf8EBAMCBaAwHQYD\nVR0lBBYwFAYIKwYBBQUHAwEGCCsGAQUFBwMCMAwGA1UdEwEB/wQCMAAwHQYDVR0O\nBBYEFByIjRbM33Z50ZE/HEjekgS/EtseMB8GA1UdIwQYMBaAFBQusxe3WFbLrlAJ\nQOYfr52LFMLGMFUGCCsGAQUFBwEBBEkwRzAhBggrBgEFBQcwAYYVaHR0cDovL3Iz\nLm8ubGVuY3Iub3JnMCIGCCsGAQUFBzAChhZodHRwOi8vcjMuaS5sZW5jci5vcmcv\nMCkGA1UdEQQiMCCCDyoub3hmb3JkZnVuLmNvbYINb3hmb3JkZnVuLmNvbTBMBgNV\nHSAERTBDMAgGBmeBDAECATA3BgsrBgEEAYLfEwEBATAoMCYGCCsGAQUFBwIBFhpo\ndHRwOi8vY3BzLmxldHNlbmNyeXB0Lm9yZzCCAQQGCisGAQQB1nkCBAIEgfUEgfIA\n8AB2AFzcQ5L+5qtFRLFemtRW5hA3+9X6R9yhc5SyXub2xw7KAAABd98LCLMAAAQD\nAEcwRQIhAKypvmPmtWdc7MkGKNmKjOOB9MLiovU+CYAqWUU/xN7xAiBQAp8XkEuh\n/nxOXiKPrR3BpjYNMYJTghGcqkYm71iaYwB2APZclC/RdzAiFFQYCDCUVo7jTRMZ\nM7/fDC8gC8xO8WTjAAABd98LCLMAAAQDAEcwRQIgTSMH1D7KvyFzIuDr8y5Z2hDW\nQ4E3xv5skGq2DEvvisoCIQCl1Z+nJeB2gpU0pbyedZQKc/ZDmvSUmx6d4ZKIiX6N\n9zANBgkqhkiG9w0BAQsFAAOCAQEAM7XDKgCWjGwnuQWH+isLMa0KuXOuoIDNwY8c\newkZD6j/Zq2VzL1/Wf9H4y4syyiXnsCgfrkZZV2OrxRAMXe/Z4oLxt30mnnqGrUy\nLOdGfICmW6Bn6WyufqnYlMTxdxxsl3MuOHImyBR0ianC0VoMhWPasOSDdtFuulDU\nvPCDXc6Ac/7PLG2kbzdkT7DzYhZGK+n1FXmQdSd0ul1CpRZFtrlI+SbA/sxd2rKf\nDD+YEf6Z8Z4gccP8caYI3WB8ljV6YM9nWcuEBqVOEE3uw+zWSPhpRrnkYUZPvq7h\npgwaELydsnGM8opA3H66pKxaa0HxgLBcVE+d0vKWM27QlAy5Vg==\n-----END CERTIFICATE-----\n\n-----BEGIN CERTIFICATE-----\nMIIEZTCCA02gAwIBAgIQQAF1BIMUpMghjISpDBbN3zANBgkqhkiG9w0BAQsFADA/\nMSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT\nDkRTVCBSb290IENBIFgzMB4XDTIwMTAwNzE5MjE0MFoXDTIxMDkyOTE5MjE0MFow\nMjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxCzAJBgNVBAMT\nAlIzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuwIVKMz2oJTTDxLs\njVWSw/iC8ZmmekKIp10mqrUrucVMsa+Oa/l1yKPXD0eUFFU1V4yeqKI5GfWCPEKp\nTm71O8Mu243AsFzzWTjn7c9p8FoLG77AlCQlh/o3cbMT5xys4Zvv2+Q7RVJFlqnB\nU840yFLuta7tj95gcOKlVKu2bQ6XpUA0ayvTvGbrZjR8+muLj1cpmfgwF126cm/7\ngcWt0oZYPRfH5wm78Sv3htzB2nFd1EbjzK0lwYi8YGd1ZrPxGPeiXOZT/zqItkel\n/xMY6pgJdz+dU/nPAeX1pnAXFK9jpP+Zs5Od3FOnBv5IhR2haa4ldbsTzFID9e1R\noYvbFQIDAQABo4IBaDCCAWQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8E\nBAMCAYYwSwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5p\nZGVudHJ1c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTE\np7Gkeyxx+tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEE\nAYLfEwEBATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2Vu\nY3J5cHQub3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0\nLmNvbS9EU1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYf\nr52LFMLGMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjANBgkqhkiG9w0B\nAQsFAAOCAQEA2UzgyfWEiDcx27sT4rP8i2tiEmxYt0l+PAK3qB8oYevO4C5z70kH\nejWEHx2taPDY/laBL21/WKZuNTYQHHPD5b1tXgHXbnL7KqC401dk5VvCadTQsvd8\nS8MXjohyc9z9/G2948kLjmE6Flh9dDYrVYA9x2O+hEPGOaEOa1eePynBgPayvUfL\nqjBstzLhWVQLGAkXXmNs+5ZnPBxzDJOLxhF2JIbeQAcH5H0tZrUlo5ZYyOqA7s9p\nO5b85o3AM/OJ+CktFBQtfvBhcJVd9wvlwPsk+uyOy2HI7mNxKKgsBTt375teA2Tw\nUdHkhVNcsAKX1H7GNNLOEADksd86wuoXvg==\n-----END CERTIFICATE-----\n"
}

resource oci_load_balancer_backend_set sp3_backendset_1 {
  health_checker {
    interval_ms         = "10000"
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_env_name}-backendset_1"
  policy           = "ROUND_ROBIN"
}

resource oci_load_balancer_backend be_1 {
  backendset_name  = oci_load_balancer_backend_set.sp3_backendset_1.name
  backup           = "false"
  drain            = "false"
  ip_address       = "10.0.1.2"
  load_balancer_id = local.Sp3_lb_id
  offline          = "false"
  port             = "80"
  weight           = "1"
}

/* resource oci_load_balancer_listener sp3_loadbalancer_listener_1 {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "60"
  }
  default_backend_set_name = oci_load_balancer_backend_set.sp3_backendset_1.name
  hostname_names = [
  ]
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_env_name}-loadbalancer_listener_1"
  port     = "443"
  protocol = "HTTP"
  rule_set_names = [
  ]
  ssl_configuration {
    certificate_name  = oci_load_balancer_certificate.sp3_loadbalancer_certificate_1.certificate_name
    cipher_suite_name = "oci-default-ssl-cipher-suite-v1"
    protocols = [
      "TLSv1.2",
    ]
    server_order_preference = "ENABLED"
    verify_depth            = "1"
    verify_peer_certificate = "false"
  }
} */

resource oci_load_balancer_listener sp3_loadbalancer_listener_1 {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "60"
  }
  default_backend_set_name = oci_load_balancer_backend_set.sp3_backendset_1.name
  hostname_names = [
  ]
  load_balancer_id = local.Sp3_lb_id
  name             = "${local.Sp3_env_name}-loadbalancer_listener_1"
  port     = "80"
  protocol = "HTTP"
  rule_set_names = [
  ]
}

/* resource oci_load_balancer_rule_set url_redirect {
  items {
    action = "REDIRECT"
    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"
      operator        = "FORCE_LONGEST_PREFIX_MATCH"
    }
    redirect_uri {
      host     = "{host}"
      path     = "/{path}"
      port     = "443"
      protocol = "https"
      query    = "?{query}"
    }
    response_code = "301"
  }
  load_balancer_id = local.Sp3_lb_id
  name             = "URLRedirect"
} */

