variable "region" {
  type    = string
  default = "us-central1"

}

variable "project_tag" {
  type = string
}

variable "db_instance_name" {
  type = string

}

variable "db_name" {
  type = string

}

variable "db_user" {
  type = string

}

variable "prefect_db_name" {
  type = string

}

variable "prefect_db_user" {
  type = string

}

variable "airbyte_db_name" {
  type = string

}

variable "airbyte_db_user" {
  type = string

}

variable "vpc" {
  type = string

}

variable "db_instance_type" {
  type = string
}

variable "db_port" {
  type = number
}
