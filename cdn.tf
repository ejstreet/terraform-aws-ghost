resource "aws_cloudfront_distribution" "ghost" {
  aliases = [
    var.domain_name
  ]

  http_version = "http2and3"
  price_class  = "PriceClass_100"

  origin {
    domain_name         = aws_instance.flatcar.public_dns
    origin_id           = aws_instance.flatcar.id
    connection_attempts = 3
    connection_timeout  = 10


    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_instance.flatcar.id
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = toset(var.uncached_paths)
    content {
      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = data.aws_cloudfront_cache_policy.disabled.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all-viewer.id
      response_headers_policy_id = data.aws_cloudfront_response_headers_policy.simple-cors.id

      compress    = true
      default_ttl = 0
      max_ttl     = 0
      min_ttl     = 0

      path_pattern           = ordered_cache_behavior.value
      target_origin_id       = aws_instance.flatcar.id
      viewer_protocol_policy = "redirect-to-https"
    }
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

data "aws_cloudfront_cache_policy" "caching-optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all-viewer" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_response_headers_policy" "simple-cors" {
  name = "Managed-SimpleCORS"
}
