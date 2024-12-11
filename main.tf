terraform {
  required_version = "~> 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80.0"
    }
  }

  # backend "s3" {
  #   bucket         = "SE_DBA-TEST-VPC-tfstate"
  #   key            = "SE_DBA-TEST-VPC-.tfstate"
  #   region         = "ap-northeast-2"
  #   profile        = "default"
  #   dynamodb_table = "TerraformStateLock"
  # }
}

provider "aws" {
  region = local.region
  # shared_config_files=["~/.aws/config"] # Or $HOME/.aws/config
  # shared_credentials_files = ["~/.aws/credentials"] # Or $HOME/.aws/credentials
  # profile        = "default"
}

data "aws_availability_zones" "available" {}

locals {
  name = "SE_DBA-TEST"
  region = var.region

  vpc_cidr = "10.0.0.0/16"
  azs = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[2]]
  az_abbr = {
    "${local.azs[0]}" = "2a"
    "${local.azs[1]}" = "2c"
  }

  public_subnet_cidr = ["10.0.0.0/24", "10.0.1.0/24"]

  private_subnet_cidr = ["10.0.2.0/24", "10.0.3.0/24"]

  SE_private_subnet_cidr = [
      for i in range(0, 20) :
      cidrsubnet("10.0.4.0/16", 8, i)
  ]

  DBA_private_subnet_cidr = [
      for i in range(0, 10) :
      cidrsubnet("10.0.128.0/16", 8, i)
  ]

  all_cidr = concat(local.public_subnet_cidr, local.private_subnet_cidr, local.SE_private_subnet_cidr, local.DBA_private_subnet_cidr)

  SE_owners = ["ckwon", "dhkil", "cgkim", "jjung", "hbjeon", "sbae", "kang-minlee", "ejang", "jun-heelee"]
  DBA_owners = ["hist_user_kimj", "swjang", "dyahn10", "ysbang", "dkim"]
}

