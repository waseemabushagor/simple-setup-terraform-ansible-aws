locals {
## set variables for the vpc,subnet,user,keyname and key path
  vpc_id           = ""
  subnet_id        = ""
  ssh_user         = ""
  key_name         = ""
  private_key_path = ""
}

provider "aws" {
#determines cloud provider and region
  region = "us-east-1"
}

resource "aws_security_group" "nginx_security_group" {
#creates security group with all inbound access to port 22 and 80 and all outbound access
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
# input ami, subnet id, instance type
  ami                         = "ami"
  subnet_id                   = ""
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
#allows ansible to wait until SSH is read
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
  }
}

output "nginx_ip" {
#puts the created ec2 instances IP address as a variable called value
  value = aws_instance.nginx.public_ip
}