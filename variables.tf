variable "region" {}
variable "compartment_ocid" {}
variable "ssh_pub_key" {}
variable "bastion_shape" {}
variable "bastion_image" {}
variable "headnode_shape" {}
variable "headnode_image" {}
variable "ad" {}
variable "name_prefix" {}
variable "env_name" {
    default = "sp3"
}