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

    cache_policy_id            = aws_cloudfront_cache_policy.caching-optimized-with-ghost-cookies.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all-viewer.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.simple-cors.id

    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = toset(var.cached_paths)
    content {
      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all-viewer.id
      response_headers_policy_id = data.aws_cloudfront_response_headers_policy.simple-cors.id

      compress = true

      path_pattern           = ordered_cache_behavior.value
      target_origin_id       = aws_instance.flatcar.id
      viewer_protocol_policy = "redirect-to-https"
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = toset(var.uncached_paths)
    content {
      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods  = ["GET", "HEAD"]

      cache_policy_id            = data.aws_cloudfront_cache_policy.disabled.id
      origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.all-viewer.id
      response_headers_policy_id = data.aws_cloudfront_response_headers_policy.simple-cors.id

      compress = true

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
    Name = var.deployment_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Avoid serving cached, logged in pages to anonymous users
resource "aws_cloudfront_cache_policy" "caching-optimized-with-ghost-cookies" {
  name = "CachingOptimizedwithCookies"

  min_ttl     = 10
  max_ttl     = 31536000
  default_ttl = 86400

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "whitelist"

      cookies {
        items = [
          "ghost-members-ssr",
        ]
      }
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all-viewer" {
  name = "Managed-AllViewerAndCloudFrontHeaders-2022-06"
}

data "aws_cloudfront_response_headers_policy" "simple-cors" {
  name = "Managed-SimpleCORS"
}
