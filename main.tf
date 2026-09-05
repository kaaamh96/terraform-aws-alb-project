
resource "aws_vpc" "customvpc" {

  cidr_block = var.vpc_cidr

  enable_dns_support = true

  enable_dns_hostnames = true

  tags = {

    Name = "customvpc"
  }



}
# internet gateway
resource "aws_internet_gateway" "custom_igw" {

  vpc_id = aws_vpc.customvpc.id

  tags = {
    Name = "custom_igw"
  }
}


# public subnet 1 

resource "aws_subnet" "public_subnet_1" {

  vpc_id = aws_vpc.customvpc.id

  cidr_block = var.public_subnet_cidr_1

  availability_zone = "eu-west-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_1"
  }

}

# public subnet 2 

resource "aws_subnet" "public_subnet_2" {

  vpc_id = aws_vpc.customvpc.id

  cidr_block = var.public_subnet_cidr_2

  availability_zone = "eu-west-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_2"
  }
}

# public route table

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.customvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id

  }

  tags = {
    Name = "public_route_table"
  }

}

# public subnet 1 route table association 

resource "aws_route_table_association" "public_subnet_1_association" {

  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# public subnet 2 route table association 

resource "aws_route_table_association" "public_subnet_2_association" {

  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id

}

#security groups


#ALB security group (public facing component so needs to accept http traffic from internet on port 80)

resource "aws_security_group" "alb_sg" {

  name        = "alb_sg"
  description = "allow HTTP traffic to ALB"
  vpc_id      = aws_vpc.customvpc.id

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0 #0 means ignores all ports since -1 protocol means allow all"
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_sg"
  }
}


#ec2 security group-- should only accept traffic from resources using alb's security group


resource "aws_security_group" "ec2_sg" {

  name        = "ec2_sg"
  description = "allow http traffic only from ALB"
  vpc_id      = aws_vpc.customvpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}