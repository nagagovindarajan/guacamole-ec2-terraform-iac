resource "aws_route53_zone" "guacamole-cloud" {
  name = "apps.guacamole.cloud"
}

resource "aws_route53_record" "guacamole-record" {
  zone_id = aws_route53_zone.guacamole-cloud.zone_id
  name    = "guacamole.apps.guacamole.cloud"
  type    = "A"
  alias {
    name                   = aws_alb.app-lb.dns_name
    zone_id                = aws_alb.app-lb.zone_id
    evaluate_target_health = true
  }
}

output "ns-servers" {
  value = aws_route53_zone.guacamole-cloud.name_servers
}

resource "aws_acm_certificate" "app_certificate" {
  domain_name       = "*.apps.guacamole.cloud"
  validation_method = "DNS"

  tags = {
    Name = "guacamole-cloud-certificate"
  }
}

resource "aws_route53_record" "certificate_verification" {
  zone_id = aws_route53_zone.guacamole-cloud.zone_id
  name    = tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.app_certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 300

  # Ensure the record is associated with the certificate's validation domain
  allow_overwrite = true
}