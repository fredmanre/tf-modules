variable "domain_name" {
  description = "Certificate domain name"
  type        = string
}

variable "subject_alternative_names" {
  description = "Certificate subject alternative names"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "DNS/Email validation method"
  type        = string
  default     = "DNS"
}

variable "zone_id" {
  description = "Route53 zone ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Certificate tags"
  type        = map(string)
  default     = {}
}