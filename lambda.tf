
################################
# Lambda Function in one region
################################

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${random_pet.this.id}-lambda1"
  description   = "My awesome lambda function"
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  publish       = true
  store_on_s3   = false

  source_path = "${path.module}/src/function"

#   attach_dead_letter_policy = true
#   dead_letter_target_arn    = aws_sqs_queue.dlq.arn

  attach_policy = true
  policy        = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

#   attach_policies    = true
#   policies           = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]
#   number_of_policies = 1

#   attach_policy_statements = true
#   policy_statements = {
#     dynamodb = {
#       effect    = "Allow",
#       actions   = ["dynamodb:BatchWriteItem"],
#       resources = ["arn:aws:dynamodb:eu-west-1:052212379155:table/Test"]
#     },
#     s3_read = {
#       effect    = "Deny",
#       actions   = ["s3:HeadObject", "s3:GetObject"],
#       resources = ["arn:aws:s3:::my-bucket/*"]
#     }
#   }

  ###########################
  # END: Additional policies
  ###########################

  tags = {
    Project = "Config360-lambda"
  }
}

###################################################
# health check region 1
module "lambda_function_health_check" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${random_pet.this.id}-lambda-health-check"
  description   = "My awesome lambda function"
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  publish       = true
  store_on_s3   = false

  source_path = "${path.module}/src/health"

#   attach_dead_letter_policy = true
#   dead_letter_target_arn    = aws_sqs_queue.dlq.arn

  attach_policy = true
  policy        = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

#   attach_policies    = true
#   policies           = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"]
#   number_of_policies = 1

#   attach_policy_statements = true
#   policy_statements = {
#     dynamodb = {
#       effect    = "Allow",
#       actions   = ["dynamodb:BatchWriteItem"],
#       resources = ["arn:aws:dynamodb:eu-west-1:052212379155:table/Test"]
#     },
#     s3_read = {
#       effect    = "Deny",
#       actions   = ["s3:HeadObject", "s3:GetObject"],
#       resources = ["arn:aws:s3:::my-bucket/*"]
#     }
#   }

  ###########################
  # END: Additional policies
  ###########################

  tags = {
    Project = "Config360-lambda"
  }
}

##################################################
# Same Lambda Function but in another region
# (used to verify conflicting IAM resource names)
##################################################

module "lambda_function_another_region" {
  source = "terraform-aws-modules/lambda/aws"

  ###########################################################
  # Using different region and IAM role name (policy prefix)
  ###########################################################
  providers = {
    aws = aws.us-east-2
  }

  role_name = "config360-lambda-us-east-2"
  ###########################################################

  function_name = "${random_pet.this.id}-lambda1"
  description   = "Copy of my awesome lambda function"
  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  publish       = true
  store_on_s3   = false

  source_path = "${path.module}/src/function"

#   attach_dead_letter_policy = true
#   dead_letter_target_arn    = aws_sqs_queue.dlq_us_east_1.arn


  tags = {
    Module = "lambda_function_in_another_region"
  }
}
