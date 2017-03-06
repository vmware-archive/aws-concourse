// Ops Manager
resource "aws_eip" "opsman" {
  instance = "${aws_instance.opsmman_az1.id}"
  vpc      = true
}
