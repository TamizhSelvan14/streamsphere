terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Project     = "StreamSphere"
      Owner       = "Tamizh Selvan"
      Environment = "Dev"
    }
  }
}
