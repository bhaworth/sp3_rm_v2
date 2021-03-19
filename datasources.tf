# Random string
resource "random_string" "deploy_id" {
  length  = 5
  special = false
  upper = false
  number = false
}
