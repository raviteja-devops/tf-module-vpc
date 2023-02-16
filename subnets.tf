module "subnets" {
  source                    = "./subnets"

  default_vpc_id            = var.default_vpc_id
  env                       = var.env
  availability_zone         = var.availability_zone

  for_each                  = var.subnets
  cidr_block                = each.value.cidr_block
  name                      = each.value.name
  internet_gw               = lookup(each.value, "internet_gw", false)
  nat_gw                    = lookup(each.value, "nat_gw", false)
  create_nat_gw             = lookup(each.value, "create_nat_gw", false)

  vpc_id                    = aws_vpc.main.id
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  tags                      = local.common_tags
}