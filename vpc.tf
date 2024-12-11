resource "aws_vpc" "SE_DBA-TEST" {
  cidr_block = local.vpc_cidr
  
  tags = {
    Name = "${local.name}-VPC"
  }
}

resource "aws_subnet" "SE_private_subnets" {
  for_each = toset(local.SE_private_subnet_cidr)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = each.key
  availability_zone = element(local.azs, index(local.SE_private_subnet_cidr, each.key) % length(local.azs))
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.SE_owners[index(local.SE_private_subnet_cidr, each.key)]}-TEST-PRI-${local.az_abbr[element(local.azs, index(local.SE_private_subnet_cidr, each.key) % length(local.azs))]}"
    Owner = local.SE_owners[index(local.SE_private_subnet_cidr, each.key)]
  }
}

resource "aws_subnet" "DBA_private_subnets" {
  for_each = toset(local.DBA_private_subnet_cidr)

  vpc_id            = aws_vpc.SE_DBA-TEST.id
  cidr_block        = each.key
  availability_zone = element(local.azs, index(local.DBA_private_subnet_cidr, each.key) % length(local.azs))
  map_public_ip_on_launch = false
  
  tags = {
    Name  = "${local.DBA_owners[index(local.DBA_private_subnet_cidr, each.key)]}-TEST-PRI-${local.az_abbr[element(local.azs, index(local.DBA_private_subnet_cidr, each.key) % length(local.azs))]}"
    Owner = local.DBA_owners[index(local.DBA_private_subnet_cidr, each.key)]
  }
}

