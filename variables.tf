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
variable "specify_worker_spec" { default = false }
variable "worker_shape" { default = "" }
variable "worker_image" { default = "" }
variable "worker_ocpus" { default = 1 }
variable "worker_ram" { default = 16 }
variable "worker_use_scratch" { default = false }



locals {
  compute_flexible_shapes = ["VM.Standard.E3.Flex"]
  Sp3_deploy_id           = random_string.deploy_id.result
  Sp3_gitrepo_secret_id   = "ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdia3ejrsbqkv6iz2ipwngjmteeduitufuu7u35sgxrx7wna"
}
