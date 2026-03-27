package main

# Refuse tout deploiement Kubernetes dont le conteneur
# s execute en tant que root (absence de runAsNonRoot: true)
deny[msg] {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.securityContext.runAsNonRoot == true
  msg := sprintf(
    "REFUSE : le conteneur '%v' tourne en root. Ajoutez securityContext.runAsNonRoot: true",
    [container.name]
  )
}
