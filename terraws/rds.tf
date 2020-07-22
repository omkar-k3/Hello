#resource "random_string" "terrastring" {
 # length = 8
  #special = true
  #override_special = "£$"
#}


#locals {
 # db_identifier = "${var.environment}-${var.terradb}"
  #db_snapshot = "${var.environment}-1"
#}


#resource "aws_secretsmanager_secret" "terrasecret" {
 # name = "terrasecret2"
#}

#resource "aws_secretsmanager_secret_version" "terrasecversion" {
 # secret_id = "${aws_secretsmanager_secret.terrasecret.id}"
  #secret_string = "${random_string.terrastring.result}"
#}

#resource "aws_db_instance" "terradb" {
 #   depends_on = [ aws_db_subnet_group.terrasubgr, aws_security_group.terrasg ]
  #  identifier = "${local.db_identifier}"
   # allocated_storage = 20
    #storage_type = "gp2"
    #engine = "mysql"
    #engine_version = "8.0.15"
    #instance_class = "${var.db_instance_class}"
    #name = "terradb1"
    #username = "terrauser"
    #password = "${aws_secretsmanager_secret_version.terrasecversion.secret_string}"
    #parameter_group_name = "${var.pgname}"
    #max_allocated_storage = 100
    #apply_immediately = "true"
    #db_subnet_group_name = "${aws_db_subnet_group.terrasubgr.id}"
    #port = 3306
    #multi_az = "true"
    #vpc_security_group_ids = ["${aws_security_group.terrasg.id}"]
    #skip_final_snapshot = "true"
    #final_snapshot_identifier = "${local.db_snapshot}"
#}