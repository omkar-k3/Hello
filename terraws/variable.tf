variable "subnets_cidr" {
    type = "list"
    default = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26", "10.0.0.192/26"]
}

variable "azs" {
    type = "list"
    default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d"]
}

variable httpcidr_block {
    type = "list"
    default = [ "0.0.0.0/0" ]
}

variable sshcidr_block {
    type = "list"
    default = [ "117.202.200.237/32"]
}

variable "instance_count" {
    default = 2
}

variable "instance_ami" {
    default = "ami-08f3d892de259504d"
}

variable "aws_region" {
    default = "us-east-1"
}

variable "db_instance_class" {
    default = "db.t2.micro"
}

variable "environment" {}

variable "dbname" {
    default = "terradb"
}

variable "terradb" {}
variable "record_prefix" {}

variable "pgname" {
    default = "default.mysql8.0"
}