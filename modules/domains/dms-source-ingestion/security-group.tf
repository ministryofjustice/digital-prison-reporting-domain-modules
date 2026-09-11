resource "aws_security_group" "dms_source_ingestion" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  ingress {
    from_port   = 1521
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}