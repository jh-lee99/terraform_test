resource "aws_vpc" "SE_DBA-TEST" {
  cidr_block = local.vpc_cidr
  
  tags = {
    Name = "${local.name}-VPC"
  }
}

resource "aws_subnet" "SE_private_subnets_a" {
  for_each = toset(local.SE_private_subnet_cidr_a)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = each.key
  availability_zone = local.azs[0]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.SE_owners[index(local.SE_private_subnet_cidr_a, each.key)]}-TEST-PRI-${local.az_suffixes[0]}}"
    Owner = local.SE_owners[index(local.SE_private_subnet_cidr_a, each.key)]
  }
}

resource "aws_subnet" "SE_private_subnets_c" {
  for_each = toset(local.SE_private_subnet_cidr_c)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = each.key
  availability_zone = local.azs[1]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.SE_owners[index(local.SE_private_subnet_cidr_c, each.key)]}-TEST-PRI-${local.az_suffixes[1]}"
    Owner = local.SE_owners[index(local.SE_private_subnet_cidr_c, each.key)]
  }
}

resource "aws_subnet" "DBA_private_subnets_a" {
  for_each = toset(local.DBA_private_subnet_cidr_a)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = each.key
  availability_zone = local.azs[0]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.DBA_owners[index(local.DBA_private_subnet_cidr_a, each.key)]}-TEST-PRI-${local.az_suffixes[0]}}"
    Owner = local.DBA_owners[index(local.DBA_private_subnet_cidr_a, each.key)]
  }
}

resource "aws_subnet" "DBA_private_subnets_c" {
  for_each = toset(local.DBA_private_subnet_cidr_c)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = each.key
  availability_zone = local.azs[1]
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.DBA_owners[index(local.DBA_private_subnet_cidr_c, each.key)]}-TEST-PRI-${local.az_suffixes[1]}"
    Owner = local.DBA_owners[index(local.DBA_private_subnet_cidr_c, each.key)]
  }
}

