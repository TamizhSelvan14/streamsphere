variable "project" {
  type        = string
  default     = "streamsphere"
  description = "Resource name prefix"
}

variable "region" {
  type        = string
  default     = "us-west-1"
  description = "AWS region"
}

variable "allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed CIDRs for ALB ingress (demo only)"
}

variable "db_username" {
  type    = string
  default = "appuser"
}
variable "db_password" {
  type    = string
  default = "apppassword123!" # for demo; use Secrets Manager in production
}

variable "frontend_domain" {
  type        = string
  default     = ""
  description = "Optional custom domain for CloudFront"
}
