output "dns_acm_validation_records" {
  value = [
    for r in aws_acm_certificate.cdn_cert.domain_validation_options : {
      type  = "CNAME"
      name  = r.resource_record_name
      value = r.resource_record_value
    }
  ]
  description = "Record(s) required by ACM to validate TLS certificates."
}

output "dns_cloudfront_record" {
  value = {
    type  = "ALIAS or CNAME"
    name  = var.domain_name
    value = aws_cloudfront_distribution.ghost.domain_name
  }
  description = "Record required to point domain at the CDN. Use an ALIAS record if the `domain_name` is the apex, otherwise use a CNAME."
}

output "ec2_connection_details" {
  value = {
    public_dns = aws_instance.flatcar.public_dns
    public_ip  = aws_instance.flatcar.public_ip
    username   = "core"
  }
  description = "Use the following to connect to the EC2 instance as admin."
}
