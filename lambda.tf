data "archive_file" "startec2_lambda_package" {  
  type = "zip"  
  source_file = "${path.module}/lambda-scripts/start_ec2instance.py" 
  output_path = "startec2.zip"
}

data "archive_file" "stopec2_lambda_package" {  
  type = "zip"  
  source_file = "${path.module}/lambda-scripts/stop_ec2instance.py" 
  output_path = "stopec2.zip"
}

resource "aws_lambda_function" "start_app_lambda" {
        function_name = "start_app_lambda"
        filename      = "startec2.zip"
        source_code_hash = data.archive_file.startec2_lambda_package.output_base64sha256
        role          = aws_iam_role.lambda_role.arn
        runtime       = "python3.8"
        handler       = "start_ec2instance.lambda_handler"
        timeout       = 60
        memory_size   = 128
}

resource "aws_lambda_function" "stop_app_lambda" {
        function_name = "stop_app_lambda"
        filename      = "stopec2.zip"
        source_code_hash = data.archive_file.stopec2_lambda_package.output_base64sha256
        role          = aws_iam_role.lambda_role.arn
        runtime       = "python3.8"
        handler       = "stop_ec2instance.lambda_handler"
        timeout       = 60
        memory_size   = 128
}