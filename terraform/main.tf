# network config first here
resource "aws_vpc" "proxy_vpc" {
  cidr_block = "10.67.67.0/24"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "proxy_subnet" {
  vpc_id            = aws_vpc.proxy_vpc.id
  cidr_block        = "10.67.67.240/28"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

resource "aws_internet_gateway" "proxy_vpc_igw" {
  vpc_id = aws_vpc.proxy_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "proxy_rtable" {
  vpc_id = aws_vpc.proxy_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proxy_vpc_igw.id
  }
}

resource "aws_route_table_association" "proxy_rtable_assoc" {
  route_table_id = aws_route_table.proxy_rtable.id
  subnet_id      = aws_subnet.proxy_subnet.id
}

# ec2 config next
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_proxy" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.proxy_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-proxy"
  }

  iam_instance_profile   = aws_iam_instance_profile.proxy_iam_profile.name
  vpc_security_group_ids = [aws_security_group.proxy_sec_group.id]

  # turns on IMDSv2
  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

}

# security groups for the ec2
resource "aws_security_group" "proxy_sec_group" {
  name   = "${var.project_name}-sec-group"
  vpc_id = aws_vpc.proxy_vpc.id
}

resource "aws_vpc_security_group_egress_rule" "proxy_egress" {
  security_group_id = aws_security_group.proxy_sec_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# wireguard handles the cidr, so we let the ingress open to anyone
resource "aws_vpc_security_group_ingress_rule" "proxy_ingress" {
  security_group_id = aws_security_group.proxy_sec_group.id
  description       = "WireGuard"
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.wireguard_port
  to_port           = var.wireguard_port
}

# make the ip address for wireguard consistent
resource "aws_eip" "proxy_ip" {
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_eip_association" "proxy_ip_assoc" {
  depends_on = [ aws_internet_gateway.proxy_vpc_igw ]
  instance_id   = aws_instance.ec2_proxy.id
  allocation_id = aws_eip.proxy_ip.id
}