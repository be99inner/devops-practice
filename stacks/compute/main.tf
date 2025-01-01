locals {
  private_subnet_ids = [
    "subnet-0e0232212ec06f77e",
    "subnet-060ce81c200ce6b4a",
    "subnet-0594d104bb1214c19",
  ]
  vpc_id = "vpc-01591d3abfc610f90"

  name = "demo-eks"

  tags = {
    Terraform   = "true"
    Environment = "demo"
  }
}

data "aws_caller_identity" "current" {}

# EKS
module "eks_bottlerocket" {
  # **NOTE**: 
  # This make EKS API endpoint public.
  # FOR demo only, for production set it to private
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name}-bottlerocket"
  cluster_version = "1.31"

  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  eks_managed_node_groups = {
    # **NOTE**:
    # this is required during setup CoreDNS, CoreDNS can't schedule during setup
    default = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m6i.large"]

      min_size = 1
      max_size = 1
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 1

      # This is not required - demonstrates how to pass additional configuration
      # Ref https://bottlerocket.dev/en/os/1.19.x/api/settings/
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    },

    control_plane = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m6i.large"]

      min_size = 1
      max_size = 5
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 1

      # This is not required - demonstrates how to pass additional configuration
      # Ref https://bottlerocket.dev/en/os/1.19.x/api/settings/
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT

      taints = {
        dedicated = {
          key    = "control-plane"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }

  }

  # Access
  access_entries = {
    # Root Account Access
    root = {
      principal_arn = "arn:aws:iam::911167885658:root"
      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = {
            namespaces = []
            type       = "cluster"
          }
        }
      }
    }
    # # Terraform Access
    # terraform = {
    #   principal_arn = "arn:aws:iam::911167885658:user/terraform"
    #   policy_associations = {
    #     example = {
    #       policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
    #       access_scope = {
    #         namespaces = ["*"]
    #         type       = "cluster"
    #       }
    #     }
    #   }
    # }
  }

  tags = local.tags
}
