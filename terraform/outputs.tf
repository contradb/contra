output "name_servers" {
  value = var.domain_name == null ? [] : aws_route53_zone.zone[0].name_servers
}

output "ip" {
  value = aws_eip.web_ip.public_ip
}

output "domain" {
  value = aws_eip.web_ip.public_dns
}

