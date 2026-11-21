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
  subnet_id = aws_subnet.proxy_subnet.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2_proxy" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id = aws_subnet.proxy_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-proxy"
  }
  
}
