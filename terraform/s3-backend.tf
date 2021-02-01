terraform {
  backend "s3" {
    # this is typically configured by passing the
    # -backend-config=production.tfbackend flag to terraform init,
    # see ./README.md for details
  }
}