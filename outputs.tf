output "cdn_certificate_validation" {
  value = aws_acm_certificate.cdn_cert.domain_validation_options
}

output "cdn_domain_name" {
  value = aws_cloudfront_distribution.ghost.domain_name
}

output "ec2_ip" {
  value = aws_instance.flatcar.public_ip
}
