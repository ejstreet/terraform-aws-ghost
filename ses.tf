locals {
  email_domain = var.email_domain != null ? var.email_domain : var.domain_name
}

resource "aws_ses_domain_identity" "default" {
  domain = local.email_domain
}

resource "aws_ses_domain_dkim" "default" {
  domain = aws_ses_domain_identity.default.domain
}

resource "aws_ses_domain_mail_from" "default" {
  domain           = aws_ses_domain_identity.default.domain
  mail_from_domain = "mail.${local.email_domain}"
}

resource "aws_ses_email_identity" "default" {
  email = "no-reply@${local.email_domain}"
}

resource "aws_iam_user" "smtp_user" {
  name = "smtp_user"
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["SES:SendEmail", "SES:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}


