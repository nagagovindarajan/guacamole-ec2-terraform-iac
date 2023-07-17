resource "aws_cloudwatch_event_rule" "lambda_ec2start_rule" {
  name        = "lambda_ec2start_rule"
  description = "EventBridge rule to trigger Start EC2 Lambda"
  schedule_expression = "cron(0 2 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_ec2start_rule.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.start_app_lambda.arn
  input_transformer {
    input_paths = {
      "payload" = "$"
    }

  input_template = <<EOF
    {
    "instance-name": "guacamole-app"
    }
    EOF
  }
}

resource "aws_lambda_permission" "event_start_permission" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_app_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_ec2start_rule.arn
}

resource "aws_cloudwatch_event_rule" "lambda_ec2stop_rule" {
  name        = "lambda_ec2stop_rule"
  description = "EventBridge rule to trigger Stop EC2 Lambda"
  schedule_expression = "cron(0 15 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_stop_target" {
  rule      = aws_cloudwatch_event_rule.lambda_ec2stop_rule.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.stop_app_lambda.arn
  input_transformer {
    input_paths = {
      "payload" = "$"
    }

  input_template = <<EOF
    {
    "instance-name": "guacamole-app"
    }
    EOF
  }
}

resource "aws_lambda_permission" "event_stop_permission" {
  statement_id  = "AllowStopEventInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_app_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_ec2stop_rule.arn
}
