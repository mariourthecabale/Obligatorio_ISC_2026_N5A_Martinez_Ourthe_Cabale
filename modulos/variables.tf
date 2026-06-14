variable "perfil" {
  type = string
}

variable "region" {
  type = string  
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet" {
  type = string
}

variable "private_subnet-2" {
  type = string
}

variable "vpc_aws_az" {
  default = "us-east-1a"
}

variable "vpc_aws_az-2" {
  default = "us-east-1b"
}

variable "ingress_rules" {
  description = "A map of ingress rules where key is description and value is port"
  type        = map(number)
  default = {
    "Allow SSH"  = 22
    "Allow HTTP" = 80
  }
}
output "ec2-id" {
  value = aws_instance.ac1-instance.id
}

output "ec2-dns" {
  value = aws_instance.ac1-instance.public_dns
}

output "ec2-public-ip" {
  value = aws_instance.ac1-instance.public_ip
}

output "lb-ip" {
  value = aws_lb.ac1-lb.dns_name
}
