

######
# ACM
######

data "aws_route53_zone" "this" {
  name = local.domain_name
  private_zone = false
}

# module "acm" {
#   source  = "terraform-aws-modules/acm/aws"
#   version = "~> 3.0"

#   domain_name               = local.domain_name
#   zone_id                   = data.aws_route53_zone.this.id # replace with zone ID
#   subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
# }


# ##########
# # Route53
# ##########


resource "aws_acm_certificate" "api" {
  domain_name       = "${local.subdomain}.${local.domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate" "api-region-2" {
  domain_name       = "${local.subdomain}.${local.domain_name}"
  validation_method = "DNS"
  provider = aws.us-east-2
}

resource "aws_route53_record" "api_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn #module.acm.acm_certificate_arn
  validation_record_fqdns = [for record in aws_route53_record.api_validation : record.fqdn]
}


resource "aws_route53_record" "api-region1" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.subdomain
  type    = "CNAME"
  ttl     = 60
  health_check_id = aws_route53_health_check.region1.id
  records = [ module.api_gateway.apigatewayv2_domain_name_target_domain_name ]
  set_identifier = "us-west-1_record"
  
  latency_routing_policy {
    region = local.region1
  }

}

resource "aws_route53_record" "api-region2" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = local.subdomain
  type    = "CNAME"
  ttl     = 60
  health_check_id = aws_route53_health_check.region2.id
  records = [ module.api_gateway_us_east_2.apigatewayv2_domain_name_target_domain_name ]
  set_identifier = "us-west-2_record"
  
  latency_routing_policy {
    region = local.region2
  }

}

#########################################
# health check region1
#########################################
resource "aws_route53_health_check" "region1" {
  fqdn              = module.api_gateway.apigatewayv2_domain_name_id
  port              = 443
  type              = "HTTPS"
  resource_path     = "/MutationEvent"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "health-check-region-1"
  }
}

#########################################
# health check region2
#########################################

resource "aws_route53_health_check" "region2" {
  fqdn              = module.api_gateway_us_east_2.apigatewayv2_domain_name_id
  port              = 443
  type              = "HTTPS"
  resource_path     = "/MutationEvent"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "health-check-region-2"
  }
}