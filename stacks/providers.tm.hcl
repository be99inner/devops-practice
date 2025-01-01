generate_hcl "_terramate_generated_providers.tf" {
  content {
    # the default values of globals are defined in config.tm.hcl in this directory

    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = global.terraform_aws_provider_version
        }
      }
    }

    terraform {
      required_version = global.terraform_version
    }
  }
}
