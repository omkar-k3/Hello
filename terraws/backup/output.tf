output "vpc_id" {
    value = "${module.terra-vpc.vpc_id}"
    description = "vpc id of terravpc"
}

output "public1" {
    value = "${module.terra-vpc.public1}"
    description = "subnet id of publicsubnet1"
}

output "public2" {
    value = "${module.terra-vpc.public2}"
    description = "subnet id of publicsubnet2"
}