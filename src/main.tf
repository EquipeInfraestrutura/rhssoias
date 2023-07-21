# Configuração do Launch Configuration
resource "aws_launch_template" "keycloak" {
  name                      = "rhsso"
  description               = "Ambiente de homolog RHSSO"
  image_id                  = var.ami_id
  key_name                  = var.keyname
  vpc_security_group_ids    = var.sg_keycloak
  instance_type             = var.instance
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "RHSSO - Homolog"
    }
  }
}

# Configuração do Application Load Balancer
resource "aws_lb" "alb_keycloak" {
  name               = "ALB-Keycloaktf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.sg_alb_keycloak
  subnets            = var.subnets

  enable_deletion_protection = false
}

# Configuração do Target Group
resource "aws_lb_target_group" "alb-keycloak" {
  name        = "TG-Keycloatf"
  port        = 8443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id
     health_check {
      protocol            = var.health_check["protocol"]
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
}

# Configuração dos Listeners
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb_keycloak.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "lb_listner_https" {
  load_balancer_arn = aws_lb.alb_keycloak.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate

  default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.alb-keycloak.arn
  }
}

resource "aws_lb_listener_certificate" "cert_keycloak" {
  listener_arn    = aws_lb_listener.lb_listner_https.arn
  certificate_arn = var.certificate
}

# Configuração do Auto Scaling Group 
resource "aws_autoscaling_group" "asg_keycloak" {
  #availability_zones        = var.availability_zones
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  target_group_arns         = ["${aws_lb_target_group.alb-keycloak.arn}"]
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.subnets

  launch_template {
    id      = aws_launch_template.keycloak.id
    version = aws_launch_template.keycloak.latest_version
 }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.asg_keycloak.id
  lb_target_group_arn    = aws_lb_target_group.alb-keycloak.arn
}

# Configuração da entrada A no Route 53
resource "aws_route53_record" "www" {
  zone_id = var.hostedzone
  name    = "acessotf"
  type    = "A"

  alias {
    name                   = aws_lb.alb_keycloak.dns_name
    zone_id                = aws_lb.alb_keycloak.zone_id
    evaluate_target_health = true
  }
}