output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}

output "public_subnet_id" {
  value = module.public_subnets
}
# we are taking the public subnet id's from the all subnet id's from subnets/output.tf