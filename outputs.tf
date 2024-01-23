output "certificate_validation" {
  value = aws_acm_certificate.cert.domain_validation_options
}

output "lb_domain_name" {
  value = aws_lb.public.dns_name
}