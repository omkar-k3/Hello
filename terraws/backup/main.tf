
provider "aws" {
    region = "us-east-1"
}

module "terra-vpc" {
    source = "./modules/aws-vpc"
}

module "terra-rds" {
    source = "./modules/aws-rds"
    
}
