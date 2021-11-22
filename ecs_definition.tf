/*
-- ecs definition
*/
resource "aws_ecs_cluster" "metabase_cluster" {
  name = "${local.service_name}_cluster"
}
resource "aws_ecs_task_definition" "metabase-task-definition" {
  family = "${local.service_name}_containers"

  container_definitions = jsonencode([
    {
      name      = "${local.service_name}_container"
      image     = "metabase/metabase"
      essential = true
      //command     = []
      //environment = []
      privileged = true

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
          containerPort = var.port
        }
      ]
    }
  ])

  execution_role_arn       = aws_iam_role.tr_ecs_metabase.arn
  requires_compatibilities = ["EC2"]
  memory                   = 1024
  cpu                      = 1024
  network_mode             = "awsvpc"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-east-1a, us-east-1b]"
  }
}

resource "aws_ecs_service" "ecs_metabase" {
  name                              = local.service_name
  cluster                           = aws_ecs_cluster.metabase_cluster.id
  task_definition                   = aws_ecs_task_definition.metabase-task-definition.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 60
  launch_type                       = "EC2"
  depends_on                        = [aws_lb_target_group.lb-metabase]
  // enable_execute_command = true

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
