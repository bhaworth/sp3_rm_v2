variable "region" {}
variable "compartment_ocid" {}
variable "ssh_pub_key" {}
variable "bastion_shape" {}
variable "bastion_image" {}
variable "headnode_shape" {}
variable "headnode_image" {}
variable "bastion_boot_size" { default = 50 }
variable "hn_boot_size" { default = 120 }
variable "hn_data_size" { default = 1024 }
variable "hn_work_size" { default = 1024 }
variable "ad" {}
variable "name_prefix" {}
variable "env_name" { default = "sp3" }
variable "deploy_web" { default = false }
variable "show_testing_others" { default = false }