variable "name" {
  description = <<-EOT
      Name of the project.
    EOT
  type        = string
}

variable "ssh-username" {
  description = <<-EOT
      Name of the ssh-username.
    EOT
  type        = string
}
variable "subnet_cidr" {
  description = <<-EOT
      CIDR for vpc
    EOT
  type        = string
}

variable "region" {
  type = string
}

variable "gcp_project" {
  type = string
}

variable "credentials" {
  type = string
}

variable "sqluser" {
  type = string
}

variable "sqlpassword" {
  type = string
}