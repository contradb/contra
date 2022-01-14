locals {
  domain_count = null == var.domain_name ? 0 : 1
}

resource "aws_route53_zone" "zone" {
  count = local.domain_count
  name  = var.domain_name
  tags = {
    Name = "contradb"
  }
}

resource "aws_route53_record" "record" {
  count   = local.domain_count
  name    = var.domain_name
  records = [aws_eip.web_ip.public_ip]
  zone_id = aws_route53_zone.zone[count.index].id
  type    = "A"
  ttl     = "3600"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zone[count.index].id
  name    = "www"
  count   = local.domain_count
  records = [aws_route53_record.record[count.index].name]
  type    = "CNAME"
  ttl     = "3600"
}
