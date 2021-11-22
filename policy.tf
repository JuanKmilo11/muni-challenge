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

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.tr_ecs_metabase.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.tr_ecs_metabase.name
}
