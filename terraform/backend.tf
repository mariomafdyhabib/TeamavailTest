terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "mariomafdy" 

    workspaces {
      name = "TeamavailTest"   
    }
  }

  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
