variable "vpc" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"

}

variable "frontend_port_name" {
  type    = string
  default = "http-frontend"

}

variable "backend_port_name" {
  type    = string
  default = "http-backend"
}

variable "frontend_port" {
  type    = number
  default = 3000
}

variable "backend_port" {
  type    = number
  default = 8002
}

variable "instance_group_name" {
  type    = string
  default = "prefect-webapp-intance-group"
}

variable "ssl_cert_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "project" {
  type = string
}

variable "backend_ssl_cert_name" {
  type = string
}

variable "cidr_block" {
  type = string
}
