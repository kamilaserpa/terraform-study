resource "aws_eks_access_entry" "example" {
  cluster_name      = aws_eks_cluster.cluster.name
  principal_arn     = data.aws_iam_user.principal_user.arn
  kubernetes_groups = ["group-1", "group-2"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "access_entry_association" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_iam_user.principal_user.arn

  access_scope {
    type       = "cluster"
    # namespaces = ["example-namespace"]
  }
}
