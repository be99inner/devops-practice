globals {
  # ### TERRAFORM ###############################################################
  #
  # ### global variables for use when generating providers
  # # all variables defined here can be overwritten in any sub-directory and on the
  # # stack level
  # # The global terraform version to use
  terraform_version             = ">= 1.0"
  terraform_backend_bucket_name = "be99inner-terraform-state"

  # # provider settings and defaults
  terraform_aws_provider_version = ">= 5.0"

  ### global variables for use when generating backend
  # all variables defined here can be overwritten in any sub-directory and on the
  # stack level

  # to demonstrate how to use gloabls in backend configuration
  # the same way you could define state buckets and path within the bucket
  # e.g. setting prefix to terramate.path
  # we use terraforms default for local backends here
  local_tfstate_path = "terraform.tfstate"

  # ### GLOBALS ##################################################################
  #
  # # global variables for use in terraform code within stacks
  # # we use providers project and location by default
  # project  = global.terraform_google_provider_project
  # location = global.terraform_google_provider_region

}
