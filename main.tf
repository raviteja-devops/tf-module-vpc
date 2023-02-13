resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-vpc" }
  )
}
# merge function to merge both tags
# for every resource main tags remain itself, only name tag we add it from resource and merge those things


resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidr[count.index]

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-public-subnet-${count.index + 1}" }
  )
}


resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets_cidr[count.index]

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-private-subnet-${count.index + 1}" }
  )
}


resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-peering" }
  )
}
# we are connecting both vpc's, one is workstation and another newly created vpc
# instead of hardcode owner id, we can get information from data.tf using aws_caller_identity module
# peer_owner_id - to which account we need to connect, my account or other account
# peer_vpc_id is default vpc id, vpc_id is new vpc created, connect both to current account
# default_vpc_id is coming from main.tfvars, we don't hard code


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-igw" }
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
# IGW cidr

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
# peering connection cidr, peering with workstation vpc

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-public-routetable" }
  )
}
# creating public route table and to route table we need add peering connection and internet-gateway


resource "aws_route_table_association" "public-rt-assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}
# now we need to associate the Route-table with Sub-nets
# we need to attach the route table to subnet manually
# count refers the number of public subnets we created and it takes them all

# TILL NOW WE CREATED A IGW AND TO THE TWO SUBNETS WE ASSOCIATED WITH PUBLIC ROUTE-TABLE THAT HAS IGW AND PEERING WITH WORKSTATION VPC


resource "aws_eip" "ngw-eip" {
  vpc      = true
}
# we need to first create a elastic ip, to create nat-gateway


resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.public.*.id[0]

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-ngw" }
  )

  depends_on = [aws_internet_gateway.igw]
}
# creating nat-gateway


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
# peering the both vpc's

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
# entry to private subnets will be through nat gateway

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-private-routetable" }
  )
}
# creating private route table, so to point the natgateway to private subnets


resource "aws_route_table_association" "private-rt-assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}


resource "aws_route" "r" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
# adding route in default vpc of workstation
# we are getting route table id through datasource of default vpc in data.tf