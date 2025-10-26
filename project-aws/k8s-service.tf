resource "kubectl_manifest" "service" {
    depends_on = [ kubectl_manifest.deployment ]
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  tupe: LoadBalancer
YAML
}