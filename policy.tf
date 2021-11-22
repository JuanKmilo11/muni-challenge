/*
-- Policy
*/
data "aws_iam_policy_document" "pd_metabase" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tr_ecs_metabase" {
  name               = "ecs_task_role_mde_mb"
  assume_role_policy = data.aws_iam_policy_document.pd_metabase.json

}

data "aws_iam_policy" "ecs_task_exec" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "rpa1" {
  role       = aws_iam_role.tr_ecs_metabase.name
  policy_arn = data.aws_iam_policy.ecs_task_exec.arn
}
