provider "aws" {
 access_key = "AKIAVL4PZYW2GW2HYUAT"
 secret_key = "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"
 region = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-0e7450a3d88d30cb0"
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

//data "aws_subnet_ids" "example" {
//  vpc_id = var.vpc_id
//}
//
//data "aws_subnet" "example" {
//  for_each = data.aws_subnet_ids.example.ids
//  id       = each.value
//}
//
//output "subnet_cidr_blocks" {
//  value = [for s in data.aws_subnet.example : s.cidr_block]
//}

resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = var.vpc_id
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Environment" = "${var.environment_tag}"
  }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "testInstance" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  count = 5
  subnet_id = "subnet-067927c820c34bc9f"
  vpc_security_group_ids = ["${aws_security_group.sg_22.id}"]
  key_name = "${aws_key_pair.ec2key.key_name}"
 tags = {
  "Environment" = "${var.environment_tag}"
 }

    provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.public_key_path)}"
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${var.public_key_path} playbook.yml"
  }
}


//output "ip"{
//  value = "${join(",", aws_instance.testInstance.*.public_ip)}"
//}

variable "instances_list" {
  default = ["i-00254c0c703757fe3", "i-00d0d8315517736b9", "i-079823bbd56d3bec5", "i-01d830e8a15a0511d", "i-0c9d79c7988668645"]
}

//resource "aws_s3_bucket" "elb_logs_yevgeniy" {
//  bucket = "elb_logs_yevgeniy"
//  acl    = "private"
//
//  tags = {
//    Name        = "elb_logs"
//    Environment = "Test"
//  }
//}

# Create a new load balancer
resource "aws_elb" "bar" {
  name               = "foobar-terraform-elb"
  availability_zones = ["us-east-1a"]

//  access_logs {
//    bucket        = "elb_logs"
//    bucket_prefix = "logs"
//    interval      = 60
//  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

//  listener {
//    instance_port      = 8000
//    instance_protocol  = "http"
//    lb_port            = 443
//    lb_protocol        = "https"
//    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
//  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = var.instances_list
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
}
