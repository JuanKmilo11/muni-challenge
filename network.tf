
/*
-- Networks
*/
resource "aws_vpc" "vpc_metabase_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc_${local.service_name} 1"
  }
}
resource "aws_internet_gateway" "metabase-igateway" {
  vpc_id = aws_vpc.vpc_metabase_1.id

  tags = {
    Name = "${local.service_name}-Internet-gateway"
  }
}
resource "aws_subnet" "metabase-subnet-1" {
  vpc_id            = aws_vpc.vpc_metabase_1.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "${local.service_name}-subnet-1"
  }
}

resource "aws_subnet" "metabase-subnet-2" {
  vpc_id            = aws_vpc.vpc_metabase_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "${local.service_name}-subnet-2"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_metabase_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.metabase-igateway.id
  }

  tags = {
    Name = "mde_mb_rt"
  }
}

resource "aws_main_route_table_association" "mra" {
  vpc_id         = aws_vpc.vpc_metabase_1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.metabase-subnet-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.metabase-subnet-2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eip" "s1" {
  vpc = true
}

resource "aws_eip" "s2" {
  vpc = true
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.s1.id
  subnet_id     = aws_subnet.metabase-subnet-1.id

  tags = {
    Name = "MDE MB NAT 1"
  }
}

resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.s2.id
  subnet_id     = aws_subnet.metabase-subnet-2.id

  tags = {
    Name = "MDE MB NAT 2"
  }
}
