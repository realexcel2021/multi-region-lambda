
module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 0"

  depends_on = [ aws_acm_certificate_validation.api ]

  name          = "${random_pet.this.id}-http"
  description   = "${random_pet.this.id} HTP api for us-east-1"
  protocol_type = "HTTP"

  create_api_domain_name = true
  
  domain_name_certificate_arn = aws_acm_certificate.api.arn # module.acm.acm_certificate_arn
  domain_name = "${local.subdomain}.${local.domain_name}"

  integrations = {
    "GET /MutationEvent" = {
      integration_type        = "AWS_PROXY"
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      credentials_arn     = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
    }
  }
}

module "api_gateway_us_east_2" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 0"

  providers = {
    aws = aws.us-east-2
  }

  name          = "${random_pet.this.id}-http"
  description   = "${random_pet.this.id} HTP api for us-east-2"
  protocol_type = "HTTP"

  create_api_domain_name = true
  domain_name_certificate_arn = aws_acm_certificate.api-region-2.arn # module.acm.acm_certificate_arn
  domain_name = "${local.subdomain}.${local.domain_name}"


  integrations = {
    "GET /MutationEvent" = {
      integration_type        = "AWS_PROXY"
      lambda_arn             = module.lambda_function_another_region.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      credentials_arn     = module.apigateway_put_events_to_lambda_us_east_1.iam_role_arn
    }
  }
}