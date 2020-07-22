provider "aws" {
    region = "us-east-1"
}


terraform {
  backend "s3" {  
    bucket = "terrabuck"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
    vpc_name = "${var.environment}-terravpc"
    igw_name = "${var.environment}-igw"
    subnet1 = "${var.environment}-pubsub1"
    subnet2 = "${var.environment}-pubsub2"
    subnet3 = "${var.environment}-privsub1"
    subnet4 = "${var.environment}-privsub2"
    publicroute = "${var.environment}-publicroute"
    privateroute = "${var.environment}-privateroute"
    sgname = "${var.environment}-terrasg"
    key_name = "${var.environment}-terrakey"
    instance_name = "${var.environment}-terrainstance"
    nacl_name = "${var.environment}-terranacl"
    lb_name = "${var.environment}-terralb"
    target_group = "${var.environment}-terratarget"
    zone_name = "${var.environment}.terracert.com"
    record_name = "${var.record_prefix}.${var.environment}.terracert.com"
    gateway_name = "${var.environment}-terranat"
    db_subnet_group = "${var.environment}-terrasubgroup"
}

resource "aws_vpc" "terrav" {
    cidr_block = "10.0.0.0/24"
    instance_tenancy = "default"
    tags = {
        Name = "${local.vpc_name}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.terrav.id}"
    tags = {
        Name = "${local.igw_name}"
    }
}

resource "aws_subnet" "public1" {
    vpc_id = "${aws_vpc.terrav.id}"
    cidr_block = "${element(var.subnets_cidr,0)}"
    availability_zone = "${element(var.azs,0)}"
    map_public_ip_on_launch = "true"
    tags = {
        Name = "${local.subnet1}"
    }
}

resource "aws_subnet" "public2" {
    vpc_id = "${aws_vpc.terrav.id}"
    cidr_block = "${element(var.subnets_cidr,1)}"
    availability_zone = "${element(var.azs,1)}"
    map_public_ip_on_launch = "true"
    tags = {
        Name = "${local.subnet2}"
    }
}

resource "aws_subnet" "priv1" {
    vpc_id = "${aws_vpc.terrav.id}"
    cidr_block = "${element(var.subnets_cidr,2)}"
    availability_zone = "${element(var.azs,2)}"
    map_public_ip_on_launch = "false"
    tags = {
        Name = "${local.subnet3}"
    }
}

resource "aws_subnet" "priv2" {
    vpc_id = "${aws_vpc.terrav.id}"
    cidr_block = "${element(var.subnets_cidr,3)}"
    availability_zone = "${element(var.azs,3)}"
    map_public_ip_on_launch = "false"
    tags = {
        Name = "${local.subnet4}"
    }
}

resource "aws_eip" "terraeip" {
    vpc = "true"
}

resource "aws_nat_gateway" "terranat" {
    subnet_id = "${aws_subnet.public1.id}"
    allocation_id = "${aws_eip.terraeip.id}"
    tags = {
        Name = "${local.gateway_name}"
    }
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "privateroute" {
    vpc_id = "${aws_vpc.terrav.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.terranat.id}"
    }
    tags = {
        Name = "${local.privateroute}"
    }
}
resource "aws_route_table" "publicroute" {
    vpc_id = "${aws_vpc.terrav.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }
    tags = {
        Name = "${local.publicroute}"
    }
}

resource "aws_route_table_association" "rta"{
    subnet_id = "${aws_subnet.public1.id}"
    route_table_id = "${aws_route_table.publicroute.id}"
}

resource "aws_route_table_association" "rta1"{
    subnet_id = "${aws_subnet.public2.id}"
    route_table_id = "${aws_route_table.publicroute.id}"
}

resource "aws_route_table_association" "rta2" {
    subnet_id = "${aws_subnet.priv1.id}"
    route_table_id = "${aws_route_table.privateroute.id}"
}

resource "aws_route_table_association" "rta3" {
    subnet_id = "${aws_subnet.priv2.id}"
    route_table_id = "${aws_route_table.privateroute.id}"
  
}

resource "aws_security_group" "terrasg" {
    name = "${local.sgname}"
    description = "Allow inbound traffic"
    vpc_id = "${aws_vpc.terrav.id}"

    ingress {
        description = "ingress rule"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "${var.httpcidr_block}"
    }
    ingress {
        description = "allow ssh traffic from my ip"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "${var.sshcidr_block}"
    }
    ingress {
        description = "Allow https traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = "${var.httpcidr_block}"
    }
    ingress {
        description = "RDS Traffic"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = "${var.sshcidr_block}"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
        Name = "terrasg"
    }
}

resource "aws_network_acl" "terranacl" {
    vpc_id = "${aws_vpc.terrav.id}"
    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        rule_no = 100
        action = "allow"
        cidr_block = "117.202.200.237/32"
    }
    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        action = "allow"
        rule_no = 101
        cidr_block = "0.0.0.0/0"
    }
    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        action = "allow"
        rule_no = 102
        cidr_block = "0.0.0.0/0"
        
    }
    egress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        rule_no = 100
        action = "allow"
        cidr_block = "117.202.200.237/32"
    }
    egress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        rule_no = 101
        action = "allow"
        cidr_block = "0.0.0.0/0"
    }
    egress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        action = "allow"
        rule_no = 102
        cidr_block = "0.0.0.0/0"
    }

    tags =  {
        Name = "${local.nacl_name}"
    }
}

resource "tls_private_key" "terratls" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terrakey" {
    key_name = "${local.key_name}"
    public_key = "${tls_private_key.terratls.public_key_openssh}"
}

resource "aws_instance" "terrainstance" {
    count = "${var.instance_count}"
    ami = "${var.instance_ami}"
    instance_type = "t2.micro"
    subnet_id = "${element(list("${aws_subnet.public1.id}","${aws_subnet.public2.id}"), count.index)}"
    vpc_security_group_ids = [ "${aws_security_group.terrasg.id}" ]
    key_name = "${aws_key_pair.terrakey.id}"
    associate_public_ip_address = "true"
    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo amazon-linux-extras install nginx1.12 -y
                sudo service nginx start
                EOF
    tags = {
        Name = "${local.instance_name}"
    }
}

resource "aws_lb" "terralb" {
    name = "${local.lb_name}"
    internal = "false"
    load_balancer_type = "application"
    security_groups = [ "${aws_security_group.terrasg.id}" ]
    subnet_mapping {
        subnet_id = "${aws_subnet.public1.id}"
    }
    subnet_mapping {
        subnet_id = "${aws_subnet.public2.id}"
    }
    enable_deletion_protection = "true"
    tags = {
        Name = "${local.lb_name}"
        Environment = "${var.environment}"
    }
}

resource "aws_lb_target_group" "terratarget" {
    name = "${local.target_group}"
    port = 80
    protocol = "HTTP"
    vpc_id = "${aws_vpc.terrav.id}"
    target_type = "instance"
}

resource "aws_lb_listener" "terralistener" {
    load_balancer_arn = "${aws_lb.terralb.arn}"
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = "arn:aws:acm:us-east-1:064178608086:certificate/18c6ba5d-937b-4045-995d-40480ebbe633"

    default_action {
        type = "forward"
        target_group_arn = "${aws_lb_target_group.terratarget.arn}"
    }
}

data "aws_instances" "terra" {
    depends_on = [aws_instance.terrainstance]
    instance_tags = {
        Name = "${local.instance_name}"
    }
}

resource "aws_lb_target_group_attachment" "terraattach" {
    count = 2
    target_group_arn = "${aws_lb_target_group.terratarget.arn}"
    target_id = "${data.aws_instances.terra.ids[count.index]}"
    port = 80
}

resource "aws_route53_zone" "terrazone" {
    name = "${local.zone_name}"
}

resource "aws_route53_record" "terrarecord" {
    name = "${local.record_name}"
    zone_id = "${aws_route53_zone.terrazone.id}"
    type = "A"

    alias {
        name = "${aws_lb.terralb.dns_name}"
        zone_id = "${aws_lb.terralb.zone_id}"
        evaluate_target_health = "true"
    }
}

resource "aws_db_subnet_group" "terrasubgr" {
    name = "${local.db_subnet_group}"
    subnet_ids = [ "${aws_subnet.priv1.id}", "${aws_subnet.priv2.id}" ]
}
