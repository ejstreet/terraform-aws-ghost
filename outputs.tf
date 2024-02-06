output "cdn_certificate_validation" {
  value = aws_acm_certificate.cdn_cert.domain_validation_options
}
