/*
-- Load Balancer
*/
resource "aws_lb_target_group" "lb-metabase" {
  name        = "lb-${local.service_name}-target-group"
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc_metabase_1.id
}

resource "aws_lb" "lb-metabase" {
  name               = "lb-${local.service_name}"
  internal           = false
  load_balancer_type = "application"
  //security_groups    = [aws_security_group.lb_sg.id]
  subnets = [aws_subnet.metabase-subnet-1.id, aws_subnet.metabase-subnet-2.id]

  tags = {
    Name = "${local.service_name}-load-balancer"
  }
}

resource "aws_lb_listener" "lbl-metabase" {
  load_balancer_arn = aws_lb.lb-metabase.arn
  port              = var.port
  protocol          = "HTTP"
  depends_on        = [aws_internet_gateway.metabase-igateway]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-metabase.arn
  }
}
