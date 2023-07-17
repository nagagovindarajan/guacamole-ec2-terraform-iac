resource "aws_cloudwatch_log_group" "guacamole" {
  name              = "guacamole-log"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" { 
  name = "vpc_flow_logs" 
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "emailapp" {
  name              = "emailapp-log"
  retention_in_days = 7
}