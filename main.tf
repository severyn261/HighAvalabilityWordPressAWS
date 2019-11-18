provider "aws" {
  region     = "${var.region}"    #AWS region
  access_key = "${var.ACK}"       #Access key
  secret_key = "${var.SCK}"       #Secret key
}

# resource "aws_vpc" "main" {
#   cidr_block           = "${var.VPC-CIDR}"
#   instance_tenancy     = "dedicated"
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     "${var.tag-Name-name}"  = "${var.tag-Name-value}"
#     "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
#   }
# }
################################################################################################################
#                                                  Subnets                                                     #
################################################################################################################
resource "aws_subnet" "pubSB" {
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "10.222.50.0/24"
  availability_zone       = "${var.AZ1}"
  map_public_ip_on_launch = true

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-pubSB"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_subnet" "pubSB2" {
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "10.222.51.0/24"
  availability_zone       = "${var.AZ2}"
  map_public_ip_on_launch = true

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-pubSB2"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_subnet" "pvZ1" {
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "10.222.52.0/24"
  availability_zone       = "${var.AZ1}"
  map_public_ip_on_launch = false

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-private-Z1"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_subnet" "pvZ2" {
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "10.222.53.0/24"
  availability_zone       = "${var.AZ2}"
  map_public_ip_on_launch = false

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-private-Z2"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_subnet" "pvDBZ1" {
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "10.222.54.0/24"
  availability_zone       = "${var.AZ1}"
  map_public_ip_on_launch = false

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-private-DB-Z1"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_subnet" "pvDBZ2" {
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "10.222.55.0/24"
  availability_zone       = "${var.AZ2}"
  map_public_ip_on_launch = false

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-private-DB-Z2"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
################################################################################################################
#                                                Gateways                                                      #
################################################################################################################
resource "aws_eip" "eip" {
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-EIP"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
# resource "aws_internet_gateway" "igw" {
#   vpc_id = "${var.vpc-id}"

#   tags = {
#     "${var.tag-Name-name}"  = "${var.tag-Name-value}-IGW"
#     "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
#   }
# }
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${aws_subnet.pubSB.id}"

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-NGW"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
################################################################################################################
#                                              Route tables                                                    #
################################################################################################################
resource "aws_route_table" "RTpub" {
  vpc_id = "${var.vpc-id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw-id}"
  }

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-RT-pub"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_route_table" "RTpv" {
  vpc_id = "${var.vpc-id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-RT-pv"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_route_table_association" "one" {
  subnet_id      = "${aws_subnet.pubSB.id}"
  route_table_id = "${aws_route_table.RTpub.id}"
}
resource "aws_route_table_association" "two" {
  subnet_id      = "${aws_subnet.pubSB2.id}"
  route_table_id = "${aws_route_table.RTpub.id}"
}
resource "aws_route_table_association" "three" {
  subnet_id      = "${aws_subnet.pvDBZ1.id}"
  route_table_id = "${aws_route_table.RTpv.id}"
}
resource "aws_route_table_association" "four" {
  subnet_id      = "${aws_subnet.pvDBZ2.id}"
  route_table_id = "${aws_route_table.RTpv.id}"
}
resource "aws_route_table_association" "five" {
  subnet_id      = "${aws_subnet.pvZ1.id}"
  route_table_id = "${aws_route_table.RTpv.id}"
}
resource "aws_route_table_association" "six" {
  subnet_id      = "${aws_subnet.pvZ2.id}"
  route_table_id = "${aws_route_table.RTpv.id}"
}
################################################################################################################
#                                            Security Groups                                                   #
################################################################################################################
resource "aws_security_group" "sgec2" {
  name        = "sg_ec2t1"
  description = "Security Group for ec2"
  vpc_id      = "${var.vpc-id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
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
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-ec2"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_security_group" "sgEFS" {
  name        = "sg_efs"
  description = "Security Group for EFS"
  vpc_id      = "${var.vpc-id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
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
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-EFS"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_security_group" "sgELB" {
  name        = "sg_elb"
  description = "Security Group for ELB"
  vpc_id      = "${var.vpc-id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
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
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-EFS"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_security_group" "sgDB" {
  name        = "sg_rds"
  description = "Security Group for DB"
  vpc_id      = "${var.vpc-id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
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
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-RDS"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
################################################################################################################
#                                                    EFS                                                       #
################################################################################################################
resource "aws_efs_file_system" "foo" {
  creation_token = "WP-Sev-TF"

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-EFS"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_efs_mount_target" "efs-mt" {
   file_system_id  = "${aws_efs_file_system.foo.id}"
   subnet_id       = "${aws_subnet.pvZ1.id}"
   security_groups = ["${aws_security_group.sgEFS.id}"]
}
resource "aws_efs_mount_target" "efs-mt2" {
   file_system_id  = "${aws_efs_file_system.foo.id}"
   subnet_id       = "${aws_subnet.pvZ2.id}"
   security_groups = ["${aws_security_group.sgEFS.id}"]
}
################################################################################################################
#                                                    RDS                                                       #
################################################################################################################
resource "aws_db_subnet_group" "dbsbg" {
  name       = "${var.tag-Name-value}-db-sg"
  subnet_ids = ["${aws_subnet.pvDBZ1.id}", "${aws_subnet.pvDBZ2.id}"]

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-RDS-SG"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_db_instance" "dbinst" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7.19"
  instance_class      = "db.t2.micro"
  identifier          = "${var.tag-Name-value}-db-test"
  skip_final_snapshot = true
  name                = "wp_myblog"
  username            = "${var.dbuser}"
  password            = "${var.dbpass}"
  port                = "3306"

  db_subnet_group_name    = "${aws_db_subnet_group.dbsbg.name}"
  vpc_security_group_ids  = ["${aws_security_group.sgDB.id}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  multi_az                = true
  backup_retention_period = 0

  tags = {
    Owner   = "${var.tag-Owner-value}"
    Name    = "${var.tag-Name-value}"
  }
  enabled_cloudwatch_logs_exports = ["audit", "general"]
}
################################################################################################################
#                                                    ELB                                                       #
################################################################################################################
resource "aws_lb_target_group" "name-tg" {
  name     = "${var.tag-Name-value}-tg-for-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"

  health_check {
    protocol            = "HTTP"
    port                = 80
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-TG"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_lb" "name-alb" {
  name                       = "${var.tag-Name-value}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.sgELB.id}"]
  subnets                    = ["${aws_subnet.pubSB.id}","${aws_subnet.pubSB2.id}"]
  enable_deletion_protection = false

  tags = {
    "${var.tag-Name-name}"  = "${var.tag-Name-value}-ALB"
    "${var.tag-Owner-name}" = "${var.tag-Owner-value}"
  }
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.name-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.name-tg.arn}"
  }
}
resource "aws_lb_listener" "front_ends" {
  load_balancer_arn = "${aws_lb.name-alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "sertificate_ARN"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.name-tg.arn}"
  }
}
resource "aws_route53_record" "www" {
  zone_id = "zone_id"
  name    = "wordpress"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.name-alb.dns_name}"
    zone_id                = "${aws_lb.name-alb.zone_id}"
    evaluate_target_health = true
  }
}
################################################################################################################
#                                                    ASG                                                       #
################################################################################################################
resource "aws_launch_configuration" "launch" {
  name_prefix     = "nameTF-"
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.sgec2.id}"]
  key_name        = "${var.key_acc}"
  user_data       = <<-EOF
                    #!/bin/bash
                    sudo apt update -y
                    sudo apt-get install -y apache2 apache2-utils
                    sudo systemctl enable apache2
                    sudo systemctl start apache
                    sudo apt-get install -y mysql-client

                    cd /tmp
                    git clone https://github.com/aws/efs-utils
                    cd efs-utils
                    sudo apt-get -y install binutils
                    ./build-deb.sh
                    sudo apt-get -y install ./build/amazon-efs-utils*deb

                    sudo rm -rf /var/www
                    sudo mkdir /var/www

                    sudo mount -t efs ${aws_efs_file_system.foo.id}:/ /var/www
                    echo "${aws_efs_file_system.foo.id}:/  /var/www/ efs defaults,_netdev 0 0" >> /etc/fstab
                    sleep 5
                    sudo add-apt-repository ppa:ondrej/php
                    sudo apt update -y
                    sudo apt-get install -y php7.0 php7.0-mysql libapache2-mod-php7.0 php7.0-cli php7.0-cgi php7.0-gd
                    sudo mkdir /var/www/html
                    sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php
                    cd /tmp
                    wget -c http://wordpress.org/latest.tar.gz
                    tar -xzvf latest.tar.gz
                    cd wordpress
                    sudo rsync -av * /var/www/html/
                    sudo chown -R www-data:www-data /var/www/html/
                    sudo chmod -R 755 /var/www/html/
                    cd /var/www/html
                    sudo mv wp-config-sample.php wp-config.php
                    
                    sudo sed -i 's/localhost/${aws_db_instance.dbinst.endpoint}/g' wp-config.php
                    sudo sed -i 's/database_name_here/${aws_db_instance.dbinst.name}/g' wp-config.php
                    sudo sed -i 's/username_here/${var.dbuser}/g' wp-config.php
                    sudo sed -i 's/password_here/${var.dbpass}/g' wp-config.php
                    sudo apt-get install openssl
                    sudo a2enmod ssl
                    sudo systemctl restart apache2.service
                    EOF
  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "name-asg" {
  name                      = "${var.tag-Name-value}-asg"
  max_size                  = 2
  min_size                  = 0
  health_check_grace_period = 300
  default_cooldown          = 60
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.launch.name}"
  vpc_zone_identifier       = ["${aws_subnet.pvZ1.id}", "${aws_subnet.pvZ2.id}"]
  target_group_arns         = ["${aws_lb_target_group.name-tg.arn}"]
  
  timeouts {
    delete = "15m"
  }
  tag {
    key                 = "${var.tag-Owner-name}"
    value               = "${var.tag-Owner-value}"
    propagate_at_launch = true
  }
  tag {
    key                 = "${var.tag-Name-name}"
    value               = "${var.tag-Name-value}"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_policy" "agents-scale-down" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.name-asg.name}"
}
resource "aws_autoscaling_policy" "agents-scale-up" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.name-asg.name}"
}
resource "aws_cloudwatch_metric_alarm" "CPU-high" {
  alarm_name          = "terraform-test-foobar5"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = ["${aws_autoscaling_policy.agents-scale-up.arn}"]
  dimensions          = {
    AutoScalingGroupName = "${aws_autoscaling_group.name-asg.name}"
  }
}
resource "aws_cloudwatch_metric_alarm" "CPU-low" {
  alarm_name          = "terraform-test-foobar5"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = ["${aws_autoscaling_policy.agents-scale-down.arn}"]
  dimensions          = {
    AutoScalingGroupName = "${aws_autoscaling_group.name-asg.name}"
  }
}
