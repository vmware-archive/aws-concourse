resource "aws_route53_zone" "pcf_zone" {
   count = "${var.using_private_zone}"
   vpc_id = "${aws_vpc.PcfVpc.id}"
   name= "${var.pcf_ert_domain}"
}

resource "aws_route53_record" "opsman" {
  count = "${var.using_private_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "opsman"
  type = "A"
  ttl = "900"
  records = ["${aws_instance.opsmman_az1.public_ip}"]
}

resource "aws_route53_record" "apps_wild_card" {
  count = "${var.using_private_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "*.apps"
  type = "CNAME"
  ttl = "900"
  records = ["${aws_elb.PcfHttpElb.dns_name}"]
}

resource "aws_route53_record" "system_wild_card" {
  count = "${var.using_private_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "*.sys"
  type = "CNAME"
  ttl = "900"
  records = ["${aws_elb.PcfHttpElb.dns_name}"]
}

resource "aws_route53_record" "ssh" {
  count = "${var.using_private_zone}"
  zone_id = "${aws_route53_zone.pcf_zone.zone_id}"
  name = "ssh.sys"
  type = "CNAME"
  ttl = "900"
  records = ["${aws_elb.PcfSshElb.dns_name}"]
}
