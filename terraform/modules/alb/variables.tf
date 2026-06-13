##Variable para nombre ALB
variable "name_alb" {
  type = string
}

##Variable para VPC
variable "vpc_id" {
  type = string
}

##Vriable para subnet pública
variable "public_subnet_ids" {
  type = list(string)
}

##Variable para security-group de ALB
variable "alb_security_group_id" {
  type = string
}