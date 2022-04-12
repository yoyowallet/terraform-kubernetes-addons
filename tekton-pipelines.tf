locals {
  tekton-pipelines = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "tekton-pipelines")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "tekton-pipelines")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "tekton-pipelines")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "tekton-pipelines")].version
      create_ns              = false
      namespace              = "tekton-pipeliness"
      enabled                = false
      default_network_policy = true
    },
    var.tekton-pipelines
  )

  values_tekton-pipelines = <<VALUES
VALUES

}

resource "kubernetes_namespace" "tekton-pipelines" {
  count = local.tekton-pipelines["enabled"] && local.tekton-pipelines["create_ns"] ? 1 : 0

  metadata {
    labels = {
      name                               = local.tekton-pipelines["namespace"]
      "${local.labels_prefix}/component" = "tekton-pipelines"
    }

    name = local.tekton-pipelines["namespace"]
  }
}

resource "helm_release" "tekton-pipelines" {
  count                 = local.tekton-pipelines["enabled"] ? 1 : 0
  repository            = local.tekton-pipelines["repository"]
  name                  = local.tekton-pipelines["name"]
  chart                 = local.tekton-pipelines["chart"]
  version               = local.tekton-pipelines["chart_version"]
  timeout               = local.tekton-pipelines["timeout"]
  force_update          = local.tekton-pipelines["force_update"]
  recreate_pods         = local.tekton-pipelines["recreate_pods"]
  wait                  = local.tekton-pipelines["wait"]
  atomic                = local.tekton-pipelines["atomic"]
  cleanup_on_fail       = local.tekton-pipelines["cleanup_on_fail"]
  dependency_update     = local.tekton-pipelines["dependency_update"]
  disable_crd_hooks     = local.tekton-pipelines["disable_crd_hooks"]
  disable_webhooks      = local.tekton-pipelines["disable_webhooks"]
  render_subchart_notes = local.tekton-pipelines["render_subchart_notes"]
  replace               = local.tekton-pipelines["replace"]
  reset_values          = local.tekton-pipelines["reset_values"]
  reuse_values          = local.tekton-pipelines["reuse_values"]
  skip_crds             = local.tekton-pipelines["skip_crds"]
  verify                = local.tekton-pipelines["verify"]
  values = [
    local.values_tekton-pipelines,
    local.tekton-pipelines["extra_values"]
  ]
  namespace = local.tekton-pipelines["create_ns"] ? kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index] : local.tekton-pipelines["namespace"]

  depends_on = [
    helm_release.kube-prometheus-stack
  ]
}

resource "kubernetes_network_policy" "tekton-pipelines_default_deny" {
  count = local.tekton-pipelines["create_ns"] && local.tekton-pipelines["enabled"] && local.tekton-pipelines["default_network_policy"] ? 1 : 0

  metadata {
    name      = "${kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index]}-default-deny"
    namespace = kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index]
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "tekton-pipelines_allow_namespace" {
  count = local.tekton-pipelines["create_ns"] && local.tekton-pipelines["enabled"] && local.tekton-pipelines["default_network_policy"] ? 1 : 0

  metadata {
    name      = "${kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index]}-allow-namespace"
    namespace = kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index]
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index]
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "tekton-pipelines_allow_ingress" {
  count = local.tekton-pipelines["enabled"] && local.tekton-pipelines["default_network_policy"] ? 1 : 0

  metadata {
    name      = "${local.tekton-pipelines["create_ns"] ? kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index] : local.tekton-pipelines["namespace"]}-allow-ingress-tekton-pipelines"
    namespace = local.tekton-pipelines["create_ns"] ? kubernetes_namespace.tekton-pipelines.*.metadata.0.name[count.index] : local.tekton-pipelines["namespace"]
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "${local.labels_prefix}/component" = "ingress"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}