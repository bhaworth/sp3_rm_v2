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
    content      = data.template_file.headnode_cloud_init.rendered
  }
}
data "template_file" "headnode_cloud_init" {
  template = file("${path.module}/scripts/headnode-cloud-config.template.yaml")

  vars = {
    bootstrap_root_sh_content   = base64gzip(data.template_file.bootstrap_root.rendered)
    bootstrap_ubuntu_sh_content = base64gzip(data.template_file.bootstrap_ubuntu.rendered)
    install_sp3_sh_content      = base64gzip(data.template_file.install_sp3.rendered)
    inject_pub_keys_sh_content  = base64gzip(data.template_file.inject_pub_keys.rendered)
  }
}

data "template_cloudinit_config" "bastion" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = data.template_file.bastion_cloud_init.rendered
  }
}
data "template_file" "bastion_cloud_init" {
  template = file("${path.module}/scripts/bastion-cloud-config.template.yaml")

  vars = {
    inject_pub_keys_sh_content = base64gzip(data.template_file.inject_pub_keys.rendered)
  }
}

data "template_file" "bootstrap_root" {
  template = file("${path.module}/scripts/bootstrap_root.sh")
}
data "template_file" "bootstrap_ubuntu" {
  template = file("${path.module}/scripts/bootstrap_ubuntu.sh")

  # Variables parsed into bootstrap_ubuntu.sh as it is encoded in to Cloud-Init
  vars = {
    deployment_id = local.Sp3_deploy_id
    tenancy_id    = var.tenancy_ocid
  }
}

data "template_file" "install_sp3.sh" {
  template = file("${path.module}/scripts/install_sp3.sh")
}

data "template_file" "inject_pub_keys.sh" {
  template = file("${path.module}/scripts/inject_pub_keys.sh")
}
