# Resource: k8s namespace
resource "kubernetes_namespace_v1" "k8s_mineo" {
  metadata {
    name = "mineo"
  }
}