# modules/alb/main.tf


# Generate a private key for the self-signed certificate
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a self-signed certificate
resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  # Common Name (CN) should be the expected domain name or ALB DNS name
  # For self-signed, you can use a placeholder or the ALB name.
  # For real certs, this would be your actual domain.
  subject {
    common_name = "${var.alb_name}.example.com" # Use a dummy domain or ALB name
    #common_name = module.alb.lb_dns_name
    organization = "URL Shortener Dev"
  }

  validity_period_hours = 8760 # 365 days (24 hours * 365 days)

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]

  # Basic constraints
  is_ca_certificate = false

  # DNS Names (important for ALB)
  # You might not know the exact ALB DNS name until after creation,
  # but for self-signed, a placeholder is fine.
  # For a real cert, you'd use your actual domain names.
  dns_names = [
    "${var.alb_name}.example.com",
    "localhost", # Useful for local testing if needed
    #"${module.alb.lb_dns_name}"
  ]

  # IP Addresses (optional, but can be useful for direct IP access in dev)
  ip_addresses = [
    "127.0.0.1"
  ]

  # Set subject alternative names (SANs) for the certificate
  # For a real certificate, this would include all domain names the ALB will serve.
  # For self-signed, this can be a placeholder.
  # For the ALB, it primarily matches the domain in the listener.
  # subject_alternative_names {
  #   dns_names = ["${var.alb_name}.example.com"]
  # }
}

# Import the self-signed certificate into AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "this" {
  private_key      = tls_private_key.this.private_key_pem
  certificate_body = tls_self_signed_cert.this.cert_pem
  # No chain needed for self-signed, but for real certs, you'd include it.
  # certificate_chain = tls_self_signed_cert.this.cert_pem_chain

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Name        = "${var.alb_name}-self-signed-cert"
  }

  # Lifecycle rule to ignore changes to the certificate body and private key
  # after creation, as ACM doesn't allow updating these directly.
  # This prevents Terraform from trying to re-import on every plan if the generated cert changes.
  lifecycle {
    ignore_changes = [
      private_key,
      certificate_body,
      certificate_chain,
    ]
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}-${var.alb_name}-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
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
    Environment = var.environment
    Project     = var.project
  }
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0" # Use a recent stable version

  name               = "${var.environment}-${var.alb_name}"
  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.alb_sg.id]

  # HTTP listener
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # Added: Redirect to HTTPS
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301" # Permanent redirect
      }
    }
  ]

  # HTTPS listener on port 443
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate.this.arn # Reference the ACM certificate ARN
      target_group_index = 0                            # Default action will be forward to this TG
    }
  ]

  # Target Group
  target_groups = [
    {
      name_prefix          = "${var.environment}"
      backend_protocol     = "HTTP"
      backend_port         = 30783
      target_type          = "instance" # Or "ip" depending on your EKS service type
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200"
      }
      tags = {
        Environment = var.environment
        Project     = var.project
      }
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Associate WAF Web ACL with the ALB directly here
resource "aws_wafv2_web_acl_association" "this" {
  # create this resource only if the 'enable_waf_association' flag is on
  count = var.enable_waf_association ? 1 : 0

  resource_arn = module.alb.lb_arn
  web_acl_arn  = var.web_acl_arn_input_to_alb

  # Explicitly depend on both the ALB and WAF modules
  # This ensures both resources are created before the association is attempted.
  depends_on = [
    module.alb,
    var.web_acl_arn_input_to_alb
  ]
}