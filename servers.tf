provider aws {
  region = "us-west-2"
}

variable "image_id" {
  type = string
  default = "ami-0dcb02d5b82da636e"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.30.0.0/16"
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "us-west-2a"
  cidr_block        = "10.30.0.0/24"

  tags = {
    Subnet = "1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "us-west-2b"
  cidr_block        = "10.30.1.0/24"

  tags = {
    Subnet = "2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "rta_1" {
  subnet_id      = "${aws_subnet.subnet_1.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_route_table_association" "rta_2" {
  subnet_id      = "${aws_subnet.subnet_2.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_security_group" "server_default" {
  name        = "server_default"
  description = "Server defaults"
  vpc_id      = "${aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "server_1" {
  ami                         = "${var.image_id}"
  instance_type               = "m5.large"
  subnet_id                   = "${aws_subnet.subnet_1.id}"
  key_name                    = "octetz"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.server_default.id}"]

  tags = {
    Name = "octetz_cp_calico_lab"
  }
}

resource "aws_instance" "server_2" {
  ami                         = "${var.image_id}"
  instance_type               = "m5.large"
  subnet_id                   = "${aws_subnet.subnet_1.id}"
  key_name                    = "octetz"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.server_default.id}"]

  tags = {
    Name = "octetz_no1_calico_lab"
  }
}

resource "aws_instance" "server_3" {
  ami                         = "${var.image_id}"
  instance_type               = "m5.large"
  subnet_id                   = "${aws_subnet.subnet_1.id}"
  key_name                    = "octetz"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.server_default.id}"]

  tags = {
    Name = "octetz_no2_calico_lab"
  }
}

resource "aws_instance" "server_4" {
  ami                         = "${var.image_id}"
  instance_type               = "m5.large"
  subnet_id                   = "${aws_subnet.subnet_2.id}"
  key_name                    = "octetz"
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.server_default.id}"]

  tags = {
    Name = "octetz_no3_calico_lab"
  }
}

output "cp" {
  value = "${aws_instance.server_1.public_ip}"
}

output "no1" {
  value = "${aws_instance.server_2.public_ip}"
}

output "no2" {
  value = "${aws_instance.server_3.public_ip}"
}

output "no3" {
  value = "${aws_instance.server_4.public_ip}"
}
