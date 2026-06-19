resource "tls_private_key" "nip" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "nip" {
  private_key_pem = tls_private_key.nip.private_key_pem

  subject {
    common_name  = var.nip_hostname
    organization = "InnovateMart"
  }

  dns_names = [var.nip_hostname]

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "nip" {
  private_key      = tls_private_key.nip.private_key_pem
  certificate_body = tls_self_signed_cert.nip.cert_pem

  tags = {
    Name = "bedrock-nip-tls"
  }
}
