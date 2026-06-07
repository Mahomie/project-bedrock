variable "cluster_name" {
  type = string
}

variable "student_id" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}
