provider "aws" {
  default_tags {
    tags = {
      environment_tag = var.environment_tag
    }
  }
}
