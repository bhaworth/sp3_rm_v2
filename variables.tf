variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_pub_key" {}
variable "bastion_shape" {}
variable "bastion_image" {}
variable "bastion_ocpus" { default = 1 }
variable "bastion_ram" { default = 16 }
variable "headnode_shape" {}
variable "headnode_image" {}
variable "headnode_ocpus" { default = 1 }
variable "headnode_ram" { default = 16 }
variable "bastion_boot_size" { default = 50 }
variable "hn_boot_size" { default = 120 }
variable "hn_data_size" { default = 1024 }
variable "hn_work_size" { default = 1024 }
variable "ad" {}
variable "name_prefix" { default = "" }
variable "env_name" { default = "sp3" }
variable "deploy_test" { default = false }
variable "show_testing_others" { default = false }
variable "specify_prefix" { default = false }
variable "worker_shape" { default = "" }
variable "worker_image" { default = "" }
variable "worker_ocpus" { default = 1 }
variable "worker_ram" { default = 16 }
variable "worker_min" { default = 1 }
variable "worker_max" { default = 1 }
variable "worker_use_scratch" { default = false }
variable "create_child_comp" { default = true }
variable "install_nginx" { default = true }
variable "create_dns" { default = true }


locals {
  compute_flexible_shapes  = ["VM.Standard.E3.Flex"]
  Sp3_deploy_id            = random_string.deploy_id.result
  Sp3_gitrepo_secret_id    = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdia3ejrsbqkv6iz2ipwngjmteeduitufuu7u35sgxrx7wna"
  Sp3dev_ml_ssl_secret_id  = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdiae2k77jlwnvi4h2fh4siah7xmvp724ljzhliireq4xyua"
  Sp3dev_ml_priv_secret_id = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdiazs7ixckx2efzk7ew6xttvaglh3t2itzpxsmadrzx5qjq"
  Sp3dev_ml_dns_zone_id    = "ocid1.dns-zone.oc1..a17008280ea14d00bda53f8202a3ed5c"
  Sp3dev_ml_dns_comp_id    = "ocid1.compartment.oc1..aaaaaaaa6gixzvmyijx7v6juqtd32nirubegjpabv7xvqs4im2i53uuqzs3a"
  Sp3dev_ml_vault_comp_id  = "ocid1.compartment.oc1..aaaaaaaao4kpjckz2pjmlict2ssrnx45ims7ttvxghlluo2tcwv6pgfdlepq"
}
