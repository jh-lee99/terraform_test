### VPC ###
resource "aws_vpc" "SE_DBA-TEST" {
  cidr_block = local.vpc_cidr
  
  tags = {
    Name = "${local.name}-VPC"
  }
}

### SUBNET ###
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
    "Name" = "${local.name}-PRI-${local.az_suffixes[count.index]}"
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

### IGW, NAT ###
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.SE_DBA-TEST.id

  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_internet_gateway_attachment" "igw_attachment" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.SE_DBA-TEST.id
}

resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat_a_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${local.name}-NGW-2a"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_a_eip" {
  domain   = "vpc"

  tags = {
    "Name" = "${local.name}-eip"
  }
}

### ROUTING TABLE ###
resource "aws_route_table" "PUB-rtb" {
  vpc_id = aws_vpc.SE_DBA-TEST.id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.igw.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
  # }

  tags = {
    Name = "${local.name}-PUB-rtb"
  }
}

resource "aws_route_table_association" "PUB-rtb" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.PUB-rtb.id
}

resource "aws_default_route_table" "PRI-rtb" {
  default_route_table_id = aws_vpc.SE_DBA-TEST.default_route_table_id

  route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_nat_gateway.ngw_a.id
  }

  # route {
  #   ipv6_cidr_block        = "::/0"
  #   egress_only_gateway_id = aws_egress_only_internet_gateway.main.id
  # }

  tags = {
    Name = "${local.name}-PRI-rtb"
  }
}

resource "aws_route_table_association" "PRI-rtb" {
  count          = length(local.SE_private_subnet_cidr_a)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.PRI-rtb.id
}

resource "aws_main_route_table_association" "PRI-rtb" {
  vpc_id         = aws_vpc.SE_DBA-TEST.id
  route_table_id = aws_default_route_table.PRI-rtb.id
}