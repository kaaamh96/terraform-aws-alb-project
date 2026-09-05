variable "aws_region" {

  default = "eu-west-1"
  type    = string
}

variable "vpc_cidr" {

  default = "10.0.0.0/16"
  type    = string

}

variable "public_subnet_cidr_1" {
  default = "10.0.0.0/24"
  type    = string
}

variable "public_subnet_cidr_2" {
  default = "10.0.1.0/24"
  type    = string
}