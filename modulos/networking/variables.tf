variable "vpc_cidr" {
  type = string
}

variable "private_subnet_1" {
  type = string
}

variable "private_subnet_2" {
  type = string
}

variable "vpc_aws_az_1" {
  default = "us-east-1a"
}

variable "vpc_aws_az_2" {
  default = "us-east-1b"
}

variable "tag_vpc" {
    type = string  
}

variable "tag_subnet_1" {
    type = string
}

variable "tag_subnet_2" {
    type = string  
}

variable "tag_subnet_pub" {
  type = string
}

variable "tag_igw" {
    type = string  
}

variable "public_subnet" {
  type = string
  description = "Variable para la subnet publica"
}