provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ubuntu_instance" {
  count         = 5
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  key_name      = "my-ssh-key"
  tags = {
    Name = "ubuntu-servers"
  }
}