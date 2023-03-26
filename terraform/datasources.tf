data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["0997201094727"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-10.04-amd64-server.*"]
  }
}