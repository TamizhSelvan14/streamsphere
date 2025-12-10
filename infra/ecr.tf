resource "aws_ecr_repository" "api" {
  name = "${var.project}-api"
  image_scanning_configuration { scan_on_push = true }
  tags = { Project = var.project }
}
resource "aws_ecr_repository" "worker" {
  name = "${var.project}-worker"
  image_scanning_configuration { scan_on_push = true }
  tags = { Project = var.project }
}
