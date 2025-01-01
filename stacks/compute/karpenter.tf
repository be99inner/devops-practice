module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = ">= 20.31.6"

  cluster_name = module.eks_bottlerocket.cluster_name

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = local.tags
}

resource "aws_eks_pod_identity_association" "karpenter" {
  cluster_name    = module.eks_bottlerocket.cluster_name
  role_arn        = module.karpenter.iam_role_arn
  namespace       = "kube-system"
  service_account = "karpenter"

  tags = local.tags
}
