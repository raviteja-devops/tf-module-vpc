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



# we allowed traffic from main vpc to default vpc, but TRAFFIC FROM default vpc is not allowed TO MAIN VPC
# we need to open traffic from both sides

# we get data of default vpc in data.tf


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-igw" }
  )
}