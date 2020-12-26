# terraform plan -out=the.tfplan -var=domain_name=contradb.org
#
# contradb.org notes:
# https://ap.www.namecheap.com/domains/domaincontrolpanel/contradb.org/domain
# Nameservers > Custom Dns
# was
#   ns1.digitalocean.com
#   ns2.digitalocean.com
#   ns3.digitalocean.com
# now
#   ns-1125.awsdns-12.org
#   ns-1730.awsdns-24.co.uk
#   ns-370.awsdns-46.com
#   ns-790.awsdns-34.net

variable "domain_name" {
  default = null
  type = string
  description = <<EOF
Leave null for no domain. 
The domain name to configure to point to the server, e.g. 'contradb.com'.
Note that for any domain sent through here to actually have authority,
a human has to go into the registrar's configuration and point the nameservers 
to the name_servers outputs. 
EOF
}

locals {
  domain_count = null == var.domain_name ? 0 : 1
}

resource "aws_route53_zone" "zone" {
  count = local.domain_count
  name = var.domain_name
}

resource "aws_route53_record" "record" {
  count = local.domain_count
  name = var.domain_name
  records = [aws_eip.web_ip.public_ip]
  zone_id = aws_route53_zone.zone[count.index].id
  type = "A"
  ttl = "60"
}

output "name_servers" {
  value = var.domain_name == null ? [] : aws_route53_zone.zone[0].name_servers
}