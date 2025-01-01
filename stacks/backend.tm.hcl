generate_hcl "_terramate_generated_backend.tf" {
  content {
    terraform {
      backend "s3" {
        bucket = global.terraform_backend_bucket_name
        key   = "devops-terramate-practice/${terramate.stack.path.relative}/terraform.tfstate"
        region = "ap-southeast-1"
      }
    }
  }
}
