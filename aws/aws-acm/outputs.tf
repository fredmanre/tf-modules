output "certificate_arn" {
  description = "ARN of the certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain_validation_options" {
  description = "Domain validation options"
  value       = aws_acm_certificate.this.domain_validation_options
}

output "validation_complete" {
  description = "Whether the certificate is validated"
  value       = var.validation_method == "DNS" && var.zone_id != "" ? aws_acm_certificate_validation.this[0].certificate_arn : null
}