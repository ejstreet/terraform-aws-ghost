resource "aws_cloudfront_distribution" "ghost" {
  aliases = [
    var.domain_name
  ]

  http_version = "http2and3"
  price_class  = "PriceClass_100"

  origin {
    domain_name         = "aws_lb.public.dns_name"
    origin_id           = "aws_lb.public.name"
    connection_attempts = 3
    connection_timeout  = 10


    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "aws_lb.public.name"
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }



  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cdn_cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_acm_certificate" "cdn_cert" {
  provider          = aws.global
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = var.instance_name
  }

  lifecycle {
    create_before_destroy = true
  }
}
