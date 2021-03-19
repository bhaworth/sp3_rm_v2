# Random string
resource "random_string" "deploy_id" {
  length  = 5
  special = false
  upper   = false
  number  = false
}

data "template_cloudinit_config" "headnode" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.cloud_init.rendered
  }
}
data "template_file" "cloud_init" {
  template = file("${path.module}/scripts/cloud-config.template.yaml")

  vars = {
    bootstrap_root_sh_content   = base64gzip(data.template_file.bootstrap_root.rendered)
    bootstrap_ubuntu_sh_content = base64gzip(data.template_file.bootstrap_ubuntu.rendered)
  }
}
data "template_file" "bootstrap_root" {
  template = file("${path.module}/scripts/bootstrap_root.sh")
}
data "template_file" "bootstrap_ubuntu" {
  template = file("${path.module}/scripts/bootstrap_ubuntu.sh")

  # Variables parsed into bootstrap_ubuntu.sh as it is encoded in to Cloud-Init
  vars = {
    deployment_id = var.deploy_id
    tenancy_id    = var.tenancy_ocid
  }
}
