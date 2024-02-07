output "dns_acm_validation_records" {
  value = [
    for r in aws_acm_certificate.cdn_cert.domain_validation_options : {
      type  = "CNAME"
      name  = r.resource_record_name
      value = r.resource_record_value
    }
  ]
}

output "dns_cloudfront_record" {
  value = {
    type  = "CNAME or ALIAS"
    name  = var.domain_name
    value = aws_cloudfront_distribution.ghost.domain_name
  }
}

output "dns_mail_dkim_records" {
  value = [
    for t in aws_ses_domain_dkim.default.dkim_tokens : {
      type  = "CNAME"
      name  = "${t}._domainkey.${local.email_domain}"
      value = "${t}.dkim.amazonses.com"
    }
  ]
}

output "dns_mail_from_mx_record" {
  value = {
    type     = "MX"
    name     = aws_ses_domain_mail_from.default.mail_from_domain
    priority = "10"
    value    = "feedback-smtp.ca-central-1.amazonses.com"
  }
}

output "dns_mail_from_txt_record" {
  value = {
    type  = "TXT"
    name  = aws_ses_domain_mail_from.default.mail_from_domain
    value = "v=spf1 include:amazonses.com ~all"
  }
}

output "ec2_connection_details" {
  value = {
    public_ip = aws_instance.flatcar.public_ip
    username  = "core"
  }
}
