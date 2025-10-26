resource "kubectl_manifest" "namespace" {
    depends_on = [ aws_eks_cluster.cluster ]
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Namespace
metadata:
  name: nginx
  namespace: nginx
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        pathType: "Prefix"
        backend:
          serviceName: test
          servicePort: 80
YAML
}