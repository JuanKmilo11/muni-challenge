/*
-- Cloudwatch
*/
resource "aws_cloudwatch_log_group" "cloudwatchg_metabase" {
  name = "Cloudwatch_${local.service_name}_group"
  tags = {
    Name = "${local.service_name}"
  }
}

resource "aws_cloudwatch_log_stream" "cloudwatchs_metabase" {
  name           = "Cloudwatch_${local.service_name}_stream"
  log_group_name = aws_cloudwatch_log_group.cloudwatchg_metabase.name

}
