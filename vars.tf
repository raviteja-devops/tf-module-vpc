variable "cidr_block" {}
variable "env" {}
variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "default_vpc_id" {}
variable "availability_zones" {}
# we are going to take a variable and give it
# we have to send this cidr_block to roboshop-infra, main.tf
# we are trying to maintain the uniformity of the variables also