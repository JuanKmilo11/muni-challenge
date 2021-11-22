/*
-- Security Groups
*/
resource "aws_security_group" "sec_group_ecs" {
  name        = "allow_ecs_inbound_${local.service_name}"
  description = "Allow inbound"
  vpc_id      = aws_vpc.vpc_metabase_1.id

  ingress {
    description = "allow connections"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group_${local.service_name}"
  }
}
