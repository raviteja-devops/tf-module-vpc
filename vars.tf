variable "cidr_block" {}
variable "env" {}
variable "default_vpc_id" {}

# we are going to take a variable and give it
# we have to send this cidr_block to roboshop-infra, main.tf
# we are trying to maintain the uniformity of the variables also