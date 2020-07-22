output "vpc_id" {
    value = "${aws_vpc.terrav.id}"
    description = "vpc id of terravpc"
}

output "public1" {
    value = "${aws_subnet.public1.id}"
    description = "subnet id of publicsubnet1"
}

output "public2" {
    value = "${aws_subnet.public2.id}"
    description = "subnet id of publicsubnet2"
}

output "vpcsecurity" {
    value = "${aws_security_group.terrasg.id}"
    description = "vpc security group id"
}

#output "passres" {
 #  value = "${random_string.terrastring.result}"
  # description = "database password to use"
#}