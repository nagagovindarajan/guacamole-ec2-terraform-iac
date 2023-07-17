# Create VPC Flow Logs for ALB
resource "aws_flow_log" "vpc_flow_logs" { 
  traffic_type = "ALL" 
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn 
  vpc_id          = aws_vpc.main.id
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
}