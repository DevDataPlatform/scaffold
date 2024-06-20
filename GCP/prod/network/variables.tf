variable "vpc_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"

}

variable "project_tag" {
  type = string
}

variable "cidr_block" {
  type = string
}
