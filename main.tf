

# following resources will be created
#VPC
# Subnets
# Route table
# Security groups
# EC2 instances
# User data
# Target group
# ALB
# Listener











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

#ec2 Instances

resource "aws_instance" "server_1" {
  ami                    = "ami-00b98fcf187a433fa"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd

              systemctl start httpd
              systemctl enable httpd

              cat <<'HTML' > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Server 1</title>

                  <style>
                      * {
                          margin: 0;
                          padding: 0;
                          box-sizing: border-box;
                      }

                      body {
                          height: 100vh;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          font-family: Arial, sans-serif;
                          background: linear-gradient(135deg, #050b18, #0a3d91);
                          color: white;
                          overflow: hidden;
                      }

                      .container {
                          text-align: center;
                          padding: 60px;
                          border: 1px solid rgba(255,255,255,0.2);
                          border-radius: 25px;
                          background: rgba(255,255,255,0.08);
                          backdrop-filter: blur(10px);
                          box-shadow: 0 20px 60px rgba(0,0,0,0.5);
                      }

                      .image-placeholder {
                          width: 180px;
                          height: 180px;
                          margin: 0 auto 30px;
                          border-radius: 50%;
                          border: 4px solid #ffffff;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          font-size: 14px;
                          background: rgba(255,255,255,0.1);
                      }

                      h1 {
                          font-size: 3rem;
                          letter-spacing: 3px;
                          text-transform: uppercase;
                          text-shadow: 0 0 20px rgba(255,255,255,0.5);
                      }

                      p {
                          margin-top: 20px;
                          font-size: 1.2rem;
                          opacity: 0.8;
                      }

                      .badge {
                          display: inline-block;
                          margin-top: 30px;
                          padding: 10px 20px;
                          border-radius: 50px;
                          background: #ffffff;
                          color: #0a3d91;
                          font-weight: bold;
                      }
                  </style>
              </head>

              <body>
                  <div class="container">

                      <div class="image-placeholder">
                          IMAGE COMING SOON
                      </div>

                      <h1>Why So Serious?<br>This Is Server 1 :D</h1>

                      <p>You have reached EC2 Instance 1</p>

                      <div class="badge">
                          SERVER 1 • ACTIVE
                      </div>

                  </div>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name = "server-1"
  }
}

resource "aws_instance" "server_2" {
  ami                    = "ami-00b98fcf187a433fa"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd

              systemctl start httpd
              systemctl enable httpd

              cat <<'HTML' > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Server 2</title>

                  <style>
                      * {
                          margin: 0;
                          padding: 0;
                          box-sizing: border-box;
                      }

                      body {
                          height: 100vh;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          font-family: Arial, sans-serif;
                          background: linear-gradient(135deg, #180505, #9b111e);
                          color: white;
                          overflow: hidden;
                      }

                      .container {
                          text-align: center;
                          max-width: 900px;
                          padding: 60px;
                          border: 1px solid rgba(255,255,255,0.2);
                          border-radius: 25px;
                          background: rgba(255,255,255,0.08);
                          backdrop-filter: blur(10px);
                          box-shadow: 0 20px 60px rgba(0,0,0,0.5);
                      }

                      .image-placeholder {
                          width: 180px;
                          height: 180px;
                          margin: 0 auto 35px;
                          border-radius: 50%;
                          border: 4px solid white;
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          font-size: 14px;
                          background: rgba(255,255,255,0.1);
                      }

                      h1 {
                          font-size: 2.7rem;
                          line-height: 1.3;
                          letter-spacing: 2px;
                          text-shadow: 0 0 20px rgba(255,255,255,0.5);
                      }

                      p {
                          margin-top: 25px;
                          font-size: 1.2rem;
                          opacity: 0.8;
                      }

                      .badge {
                          display: inline-block;
                          margin-top: 30px;
                          padding: 10px 20px;
                          border-radius: 50px;
                          background: white;
                          color: #9b111e;
                          font-weight: bold;
                      }
                  </style>
              </head>

              <body>
                  <div class="container">

                      <div class="image-placeholder">
                          IMAGE COMING SOON
                      </div>

                      <h1>
                          You merely adopted Server 2,<br>
                          I was born in it, molded by it!!!
                      </h1>

                      <p>You have reached EC2 Instance 2</p>

                      <div class="badge">
                          SERVER 2 • ACTIVE
                      </div>

                  </div>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name = "server-2"
  }
}



#Target group 
resource "aws_lb_target_group" "alb_target_group" {

  name     = "alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.customvpc.id


  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "alb-target-group"
  }
}

# target group attachments


resource "aws_lb_target_group_attachment" "server_1_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "server_2_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.server_2.id
  port             = 80
}


#ALB

resource "aws_lb" "application_load_balancer" {

  name = "application-load-balancer"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id

  ]

  tags = {
    Name = "application-load-balancer"
  }

}

resource "aws_lb_listener" "http_listerner" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}