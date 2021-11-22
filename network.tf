
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

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [aws_subnet.metabase-subnet-1.id, aws_subnet.metabase-subnet-2.id]
}

