/*
-- ecs definition
*/

locals {
  container = [
    {
      name       = "${local.service_name}_container"
      image      = "metabase/metabase"
      essential  = true
      privileged = true
      memory     = 1024
      cpu        = 1024

      "logConfiguration" : {

        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.cloudwatchg_metabase.name,
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : aws_cloudwatch_log_stream.cloudwatchs_metabase.name
        }
      }
      portMappings = [
        {
          "containerPort" = var.port
          "hostPort"      = var.port
        }
      ]
      environment = [
        {
          name  = "MB_DB_TYPE"
          value = "mysql"
        },
        {
          name  = "MB_DB_DBNAME"
          value = aws_db_instance.mysql_metabase.name
        },
        {
          name  = "MB_DB_PORT"
          value = tostring(aws_db_instance.mysql_metabase.port)
        },
        {
          name  = "MB_DB_USER"
          value = aws_db_instance.mysql_metabase.username
        },
        {
          name  = "MB_DB_PASS"
          value = aws_db_instance.mysql_metabase.password
        },
        {
          name  = "MB_DB_HOST"
          value = aws_db_instance.mysql_metabase.endpoint
        },
    ] }
  ]
}

resource "aws_ecs_cluster" "metabase_cluster" {
  name = "${local.service_name}_cluster"
}

data "template_file" "user_data" {
  template = file("user_data.sh")

  vars = {
    ecs_cluster = aws_ecs_cluster.metabase_cluster.name
  }
}
resource "aws_key_pair" "instance_key" {
  key_name   = "instance_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

data "aws_ami" "ecs_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

resource "aws_launch_configuration" "instancec_metabase" {
  name                 = "metabase_instance"
  image_id             = data.aws_ami.ecs_image.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  user_data            = data.template_file.user_data.rendered
  security_groups      = [aws_security_group.sec_group_ecs.id]
  key_name             = aws_key_pair.instance_key.key_name
}

resource "aws_autoscaling_group" "asg" {
  name = "${local.service_name}-asg"

  launch_configuration = aws_launch_configuration.instancec_metabase.name
  vpc_zone_identifier  = [aws_subnet.metabase-subnet-1.id, aws_subnet.metabase-subnet-2.id]
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1

  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_ecs_task_definition" "metabase-task-definition" {
  family                   = "${local.service_name}_containers"
  execution_role_arn       = aws_iam_role.tr_ecs_metabase.arn
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  container_definitions    = jsonencode(local.container)
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }

  tags = {
    Name = "${local.service_name}_task"
  }
}
resource "aws_ecs_service" "ecs_metabase" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.metabase_cluster.id
  task_definition = aws_ecs_task_definition.metabase-task-definition.arn
  desired_count   = 2
  launch_type     = "EC2"
  depends_on      = [aws_lb_target_group.lb-metabase]

  load_balancer {
    target_group_arn = aws_lb_target_group.lb-metabase.arn
    container_name   = "${local.service_name}_container"
    container_port   = var.port
  }

  network_configuration {
    subnets         = [aws_subnet.metabase-subnet-1.id, aws_subnet.metabase-subnet-2.id]
    security_groups = [aws_security_group.sec_group_ecs.id]
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}
