resource "aws_iam_policy" "s3_access_policy" {
  name        = "acm-cert-policy"
  description = "IAM policy for ACM certificate management"

  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role" "app_ec2_role" {
  name = "app-ec2-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.app_ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "app_ec2_profile" {
  name = "app_ec2_profile"
  role = aws_iam_role.app_ec2_role.name
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CloudWatchLogsPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Sid": "OtherPermissions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StopInstances",
        "ec2:StartInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Create VPC Flow Logs IAM Role
resource "aws_iam_role" "flow_logs_role" { 
  name = "flow_logs_role" 
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
  }
  EOF
}

# Attach VPC Flow Logs IAM Policy
resource "aws_iam_policy" "flow_logs_policy" { 
  name = "flow_logs_policy" 
  description = "Policy for VPC Flow Logs" 
  policy = <<EOF
{
"Version": "2012-10-17",
"Statement":[
  {
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ec2:CreateFlowLogs",
      "ec2:DeleteFlowLogs",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ],
    "Resource": "*"
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "flow_logs_policy_attachment" {
  policy_arn = aws_iam_policy.flow_logs_policy.arn 
  role = aws_iam_role.flow_logs_role.name
}

