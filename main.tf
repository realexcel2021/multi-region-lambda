provider "aws" {
  region = local.region1

}

provider "aws" {
  region = local.region2
  alias  = "us-east-2"

}

resource "random_pet" "this" {
  length = 2
}

locals {
  domain_name = "devopslord.com" # trimsuffix(data.aws_route53_zone.this.name, ".")
  subdomain   = "ha-serverless"
  region1 = "us-east-1"
  region2 = "us-weat-1"
}