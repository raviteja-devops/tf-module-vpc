resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-vpc" }
  )
}
# merge function to merge both tags
# for every resource main tags remain itself, only name tag we add it from resource and merge those things


resource "aws_subnet" "main" {
  count = length(var.subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnets_cidr[count.index]

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-subnet" }
  )
}