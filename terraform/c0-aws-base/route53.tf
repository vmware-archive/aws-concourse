resource "aws_route53_zone" "pcf_zone" {
   count = "${var.create_dns_zone}"
   name= "${var.pcf_ert_domain}"
}

resource "aws_route53_record" "pcf-ns" {
    count = "${var.create_dns_zone}"
    zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
    name = "${var.pcf_ert_domain}"
    type = "NS"
    ttl = "30"
    records = ["${split(",", var.name_server_records)}"]
}

resource "aws_route53_record" "opsman" {
  count = "${var.create_dns_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "opsman"
  type = "A"
  ttl = "900"
  records = ["${aws_instance.opsmman_az1.public_ip}"]
}

resource "aws_route53_record" "apps_wild_card" {
  count = "${var.create_dns_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "*.apps"
  type = "CNAME"
  ttl = "900"
  records = ["${aws_elb.PcfHttpElb.dns_name}"]
}

resource "aws_route53_record" "system_wild_card" {
  count = "${var.create_dns_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "*.sys"
  type = "CNAME"
  ttl = "900"
  records = ["${aws_elb.PcfHttpElb.dns_name}"]
}

resource "aws_route53_record" "ssh" {
  count = "${var.create_dns_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "ssh.sys"
  type = "CNAME"
  ttl = "900"
  records = ["${aws_elb.PcfSshElb.dns_name}"]
}
