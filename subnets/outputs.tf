output "subnet_ids" {
  value = aws_subnet.main.*.id
}

# sending all the subnets id to output.tf