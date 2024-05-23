module "apigateway_put_events_to_lambda_us_east_1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.0"

  create_role = true

  role_name         = "apigateway-put-events-to-lambda_us-east_1"
  role_requires_mfa = false

  trusted_role_services = ["apigateway.amazonaws.com"]

  custom_role_policy_arns = [
    module.apigateway_put_events_to_lambda_policy.arn
  ]
}

module "apigateway_put_events_to_lambda_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.0"

  name        = "apigateway-put-events-to-lambda-global"
  description = "Allow PutEvents to EventBridge"

  policy = data.aws_iam_policy_document.apigateway_put_events_to_lambda_policy_doc.json
}

#####################################
# Policy Documents

data "aws_iam_policy_document" "apigateway_put_events_to_lambda_policy_doc" {
  statement {
    sid       = "AllowInvokeFunction"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.lambda_function_another_region.lambda_function_arn, module.lambda_function.lambda_function_arn]
  }
}