resource "aws_vpc" "gradle_java_vpc" {
  cidr_block = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "prod"
  }
}

resource "aws_subnet" "gradle_java_public_subnet" {
  vpc_id                  = aws_vps.gradle_java_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1"
  tags = {
    Name = "prod-public"
  }
}

resource "aws_internet_gateway" "gradle_java_internet_gateway" {
  vpc_id = aws_vpc.gradle_java_vpc.id
  tags = {
    Name = "prod-igw"
  }
}

resource "aws_route_table" "gradle_java_public_rt" {
  vpc_id = aws_vpc.gradle_java_vpc.id
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.gradle_java_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gradle_java_internet_gateway.id
}

resource "aws_route_table_association" "gradle_java_public_assoc" {
  subnet_id      = aws_subnet.gradle_java_public_subnet.id
  route_table_id = aws_route_table.gradle_java_public_rt.id
}

resource "aws_security_group" "gradle_java_sg" {
  name        = "pro_ig"
  description = "prod security group"
  vpc_id      = aws_vpc.gradle_java_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["190.7.8.1/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}

resource "aws_instance" "prod-node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.my_auth.id
  vpc_security_group_ids = [aws_security_group.gradle_java_sg.id]
  subnet_id              = aws_subnet.gradle_java_public_subnet.id
  user_data              = file("userdata.tpl")
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name = "prod-node"
  }
}