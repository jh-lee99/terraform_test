resource "aws_vpc" "SE_DBA-TEST" {
  cidr_block = local.vpc_cidr
  
  tags = {
    Name = "${local.name}-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = local.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${local.name}-PUB-${local.az_suffixes[count.index]}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = local.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    "Name" = "${local.name}-PUB-${local.az_suffixes[count.index]}"
  }
}

resource "aws_subnet" "SE_private_subnets_a" {
  # for_each = toset(local.SE_private_subnet_cidr_a)
  count = length(local.SE_private_subnet_cidr_a)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = local.SE_private_subnet_cidr_a[count.index]
  availability_zone = local.azs[0]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.SE_owners[count.index]}-TEST-PRI-${local.az_suffixes[0]}"
    Owner = local.SE_owners[count.index]
    group = "SE"
  }
}

resource "aws_subnet" "SE_private_subnets_c" {
  count = length(local.SE_private_subnet_cidr_c)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = local.SE_private_subnet_cidr_c[count.index]
  availability_zone = local.azs[1]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.SE_owners[count.index]}-TEST-PRI-${local.az_suffixes[1]}"
    Owner = local.SE_owners[count.index]
    group = "SE"
  }
}

resource "aws_subnet" "DBA_private_subnets_a" {
  count = length(local.DBA_private_subnet_cidr_a)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = local.DBA_private_subnet_cidr_a[count.index]
  availability_zone = local.azs[0]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.DBA_owners[count.index]}-TEST-PRI-${local.az_suffixes[0]}"
    Owner = local.DBA_owners[count.index]
    group = "DBA"
  }
}

resource "aws_subnet" "DBA_private_subnets_c" {
  count = length(local.DBA_private_subnet_cidr_c)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = local.DBA_private_subnet_cidr_c[count.index]
  availability_zone = local.azs[1]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.DBA_owners[count.index]}-TEST-PRI-${local.az_suffixes[1]}"
    Owner = local.DBA_owners[count.index]
    group = "DBA"
  }
}

