

#--------------------------------------------------------
### VPC & Subnets

data "aws_subnet" "wordpress" {
  id = "${var.subnet_id}"
}

data "aws_subnet" "wordpress2" {
  id = "${var.subnet2_id}"
}

resource "aws_db_subnet_group" "wordpress" {
  name       = "main"
  subnet_ids = ["${data.aws_subnet.wordpress.id}","${data.aws_subnet.wordpress2.id}"]

  tags = "${var.tags}"
}
