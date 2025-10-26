resource "kubectl_manifest" "deployment" {
  depends_on = [kubectl_manifest.namespace]
  yaml_body  = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  namespace: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    azure/frontdoor: enabled
spec:
    replicas: 3
    selector:
        matchLabels:
            app: ngins
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
                - name: nginx
                  imagem: nginx::1.25
                  ports:
                    - containerPort: 80
YAML
}
