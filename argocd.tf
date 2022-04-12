locals {
  argocd = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argocd
  )

  values_argocd = <<-VALUES
    redis-ha:
      enabled: true

    controller:
      enableStatefulSet: true

    server:
      autoscaling:
      enabled: true
      minReplicas: 2

    repoServer:
      autoscaling:
        enabled: true
        minReplicas: 2
    VALUES

  argo-events = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argo-events
  )

  values_argo-events = <<-VALUES
    VALUES

  argo-rollouts = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argo-rollouts
  )

  values_argo-rollouts = <<-VALUES
    VALUES

  argo-workflows = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argo-workflows
  )

  values_argo-workflows = <<-VALUES
    VALUES

  argocd-applicationset = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-applicationset")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-applicationset")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-applicationset")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-applicationset")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argocd-applicationset
  )

  values_argocd-applicationset = <<-VALUES
    VALUES

  argocd-image-updater = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-image-updater")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-image-updater")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-image-updater")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-image-updater")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argocd-image-updater
  )

  values_argocd-image-updater = <<-VALUES
    VALUES

  argocd-notifications = merge(
    local.helm_defaults,
    {
      name                   = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-notifications")].name
      chart                  = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-notifications")].name
      repository             = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-notifications")].repository
      chart_version          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argocd-notifications")].version
      namespace              = "argocd"
      enabled                = false
      create_ns              = false
      default_network_policy = true
    },
    var.argocd-notifications
  )

  values_argocd-notifications = <<-VALUES
    VALUES
}

resource "kubernetes_namespace" "argocd" {
  count = local.argocd["enabled"] && local.argocd["create_ns"] ? 1 : 0

  metadata {
    labels = {
      name                               = local.argocd["namespace"]
      "${local.labels_prefix}/component" = "argocd"
    }

    name = local.argocd["namespace"]
  }
}

resource "helm_release" "argocd" {
  count                 = local.argocd["enabled"] ? 1 : 0
  repository            = local.argocd["repository"]
  name                  = local.argocd["name"]
  chart                 = local.argocd["chart"]
  version               = local.argocd["chart_version"]
  timeout               = local.argocd["timeout"]
  force_update          = local.argocd["force_update"]
  recreate_pods         = local.argocd["recreate_pods"]
  wait                  = local.argocd["wait"]
  atomic                = local.argocd["atomic"]
  cleanup_on_fail       = local.argocd["cleanup_on_fail"]
  dependency_update     = local.argocd["dependency_update"]
  disable_crd_hooks     = local.argocd["disable_crd_hooks"]
  disable_webhooks      = local.argocd["disable_webhooks"]
  render_subchart_notes = local.argocd["render_subchart_notes"]
  replace               = local.argocd["replace"]
  reset_values          = local.argocd["reset_values"]
  reuse_values          = local.argocd["reuse_values"]
  skip_crds             = local.argocd["skip_crds"]
  verify                = local.argocd["verify"]
  values = [
    local.values_argocd,
    local.argocd["extra_values"]
  ]
  namespace = local.argocd["create_ns"] ? kubernetes_namespace.argocd.*.metadata.0.name[count.index] : local.argocd["namespace"]
}

resource "helm_release" "argo-events" {
  count                 = local.argo-events["enabled"] ? 1 : 0
  repository            = local.argo-events["repository"]
  name                  = local.argo-events["name"]
  chart                 = local.argo-events["chart"]
  version               = local.argo-events["chart_version"]
  timeout               = local.argo-events["timeout"]
  force_update          = local.argo-events["force_update"]
  recreate_pods         = local.argo-events["recreate_pods"]
  wait                  = local.argo-events["wait"]
  atomic                = local.argo-events["atomic"]
  cleanup_on_fail       = local.argo-events["cleanup_on_fail"]
  dependency_update     = local.argo-events["dependency_update"]
  disable_crd_hooks     = local.argo-events["disable_crd_hooks"]
  disable_webhooks      = local.argo-events["disable_webhooks"]
  render_subchart_notes = local.argo-events["render_subchart_notes"]
  replace               = local.argo-events["replace"]
  reset_values          = local.argo-events["reset_values"]
  reuse_values          = local.argo-events["reuse_values"]
  skip_crds             = local.argo-events["skip_crds"]
  verify                = local.argo-events["verify"]
  namespace             = local.argo-events["namespace"]
  values = [
    local.values_argo-events,
    local.argo-events["extra_values"]
  ]
  depends_on = [
    helm_release.argocd
  ]
}

resource "helm_release" "argo-rollouts" {
  count                 = local.argo-rollouts["enabled"] ? 1 : 0
  repository            = local.argo-rollouts["repository"]
  name                  = local.argo-rollouts["name"]
  chart                 = local.argo-rollouts["chart"]
  version               = local.argo-rollouts["chart_version"]
  timeout               = local.argo-rollouts["timeout"]
  force_update          = local.argo-rollouts["force_update"]
  recreate_pods         = local.argo-rollouts["recreate_pods"]
  wait                  = local.argo-rollouts["wait"]
  atomic                = local.argo-rollouts["atomic"]
  cleanup_on_fail       = local.argo-rollouts["cleanup_on_fail"]
  dependency_update     = local.argo-rollouts["dependency_update"]
  disable_crd_hooks     = local.argo-rollouts["disable_crd_hooks"]
  disable_webhooks      = local.argo-rollouts["disable_webhooks"]
  render_subchart_notes = local.argo-rollouts["render_subchart_notes"]
  replace               = local.argo-rollouts["replace"]
  reset_values          = local.argo-rollouts["reset_values"]
  reuse_values          = local.argo-rollouts["reuse_values"]
  skip_crds             = local.argo-rollouts["skip_crds"]
  verify                = local.argo-rollouts["verify"]
  namespace             = local.argo-rollouts["namespace"]
  values = [
    local.values_argo-rollouts,
    local.argo-rollouts["extra_values"]
  ]
  depends_on = [
    helm_release.argocd
  ]
}

resource "helm_release" "argo-workflows" {
  count                 = local.argo-workflows["enabled"] ? 1 : 0
  repository            = local.argo-workflows["repository"]
  name                  = local.argo-workflows["name"]
  chart                 = local.argo-workflows["chart"]
  version               = local.argo-workflows["chart_version"]
  timeout               = local.argo-workflows["timeout"]
  force_update          = local.argo-workflows["force_update"]
  recreate_pods         = local.argo-workflows["recreate_pods"]
  wait                  = local.argo-workflows["wait"]
  atomic                = local.argo-workflows["atomic"]
  cleanup_on_fail       = local.argo-workflows["cleanup_on_fail"]
  dependency_update     = local.argo-workflows["dependency_update"]
  disable_crd_hooks     = local.argo-workflows["disable_crd_hooks"]
  disable_webhooks      = local.argo-workflows["disable_webhooks"]
  render_subchart_notes = local.argo-workflows["render_subchart_notes"]
  replace               = local.argo-workflows["replace"]
  reset_values          = local.argo-workflows["reset_values"]
  reuse_values          = local.argo-workflows["reuse_values"]
  skip_crds             = local.argo-workflows["skip_crds"]
  verify                = local.argo-workflows["verify"]
  namespace             = local.argo-workflows["namespace"]
  values = [
    local.values_argo-workflows,
    local.argo-workflows["extra_values"]
  ]
  depends_on = [
    helm_release.argocd
  ]
}

resource "helm_release" "argocd-applicationset" {
  count                 = local.argocd-applicationset["enabled"] ? 1 : 0
  repository            = local.argocd-applicationset["repository"]
  name                  = local.argocd-applicationset["name"]
  chart                 = local.argocd-applicationset["chart"]
  version               = local.argocd-applicationset["chart_version"]
  timeout               = local.argocd-applicationset["timeout"]
  force_update          = local.argocd-applicationset["force_update"]
  recreate_pods         = local.argocd-applicationset["recreate_pods"]
  wait                  = local.argocd-applicationset["wait"]
  atomic                = local.argocd-applicationset["atomic"]
  cleanup_on_fail       = local.argocd-applicationset["cleanup_on_fail"]
  dependency_update     = local.argocd-applicationset["dependency_update"]
  disable_crd_hooks     = local.argocd-applicationset["disable_crd_hooks"]
  disable_webhooks      = local.argocd-applicationset["disable_webhooks"]
  render_subchart_notes = local.argocd-applicationset["render_subchart_notes"]
  replace               = local.argocd-applicationset["replace"]
  reset_values          = local.argocd-applicationset["reset_values"]
  reuse_values          = local.argocd-applicationset["reuse_values"]
  skip_crds             = local.argocd-applicationset["skip_crds"]
  verify                = local.argocd-applicationset["verify"]
  namespace             = local.argocd-applicationset["namespace"]
  values = [
    local.values_argocd-applicationset,
    local.argocd-applicationset["extra_values"]
  ]
  depends_on = [
    helm_release.argocd
  ]
}

resource "helm_release" "argocd-image-updater" {
  count                 = local.argocd-image-updater["enabled"] ? 1 : 0
  repository            = local.argocd-image-updater["repository"]
  name                  = local.argocd-image-updater["name"]
  chart                 = local.argocd-image-updater["chart"]
  version               = local.argocd-image-updater["chart_version"]
  timeout               = local.argocd-image-updater["timeout"]
  force_update          = local.argocd-image-updater["force_update"]
  recreate_pods         = local.argocd-image-updater["recreate_pods"]
  wait                  = local.argocd-image-updater["wait"]
  atomic                = local.argocd-image-updater["atomic"]
  cleanup_on_fail       = local.argocd-image-updater["cleanup_on_fail"]
  dependency_update     = local.argocd-image-updater["dependency_update"]
  disable_crd_hooks     = local.argocd-image-updater["disable_crd_hooks"]
  disable_webhooks      = local.argocd-image-updater["disable_webhooks"]
  render_subchart_notes = local.argocd-image-updater["render_subchart_notes"]
  replace               = local.argocd-image-updater["replace"]
  reset_values          = local.argocd-image-updater["reset_values"]
  reuse_values          = local.argocd-image-updater["reuse_values"]
  skip_crds             = local.argocd-image-updater["skip_crds"]
  verify                = local.argocd-image-updater["verify"]
  namespace             = local.argocd-image-updater["namespace"]
  values = [
    local.values_argocd-image-updater,
    local.argocd-image-updater["extra_values"]
  ]
  depends_on = [
    helm_release.argocd
  ]
}

resource "helm_release" "argocd-notifications" {
  count                 = local.argocd-notifications["enabled"] ? 1 : 0
  repository            = local.argocd-notifications["repository"]
  name                  = local.argocd-notifications["name"]
  chart                 = local.argocd-notifications["chart"]
  version               = local.argocd-notifications["chart_version"]
  timeout               = local.argocd-notifications["timeout"]
  force_update          = local.argocd-notifications["force_update"]
  recreate_pods         = local.argocd-notifications["recreate_pods"]
  wait                  = local.argocd-notifications["wait"]
  atomic                = local.argocd-notifications["atomic"]
  cleanup_on_fail       = local.argocd-notifications["cleanup_on_fail"]
  dependency_update     = local.argocd-notifications["dependency_update"]
  disable_crd_hooks     = local.argocd-notifications["disable_crd_hooks"]
  disable_webhooks      = local.argocd-notifications["disable_webhooks"]
  render_subchart_notes = local.argocd-notifications["render_subchart_notes"]
  replace               = local.argocd-notifications["replace"]
  reset_values          = local.argocd-notifications["reset_values"]
  reuse_values          = local.argocd-notifications["reuse_values"]
  skip_crds             = local.argocd-notifications["skip_crds"]
  verify                = local.argocd-notifications["verify"]
  namespace             = local.argocd-notifications["namespace"]
  values = [
    local.values_argocd-notifications,
    local.argocd-notifications["extra_values"]
  ]
  depends_on = [
    helm_release.argocd
  ]
}

resource "kubernetes_network_policy" "argocd_default_deny" {
  count = local.argocd["create_ns"] && local.argocd["enabled"] && local.argocd["default_network_policy"] ? 1 : 0

  metadata {
    name      = "${kubernetes_namespace.argocd.*.metadata.0.name[count.index]}-default-deny"
    namespace = kubernetes_namespace.argocd.*.metadata.0.name[count.index]
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd_allow_namespace" {
  count = local.argocd["create_ns"] && local.argocd["enabled"] && local.argocd["default_network_policy"] ? 1 : 0

  metadata {
    name      = "${kubernetes_namespace.argocd.*.metadata.0.name[count.index]}-allow-namespace"
    namespace = kubernetes_namespace.argocd.*.metadata.0.name[count.index]
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.argocd.*.metadata.0.name[count.index]
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argo-events_default_deny" {
  count = local.argocd["create_ns"] && local.argo-events["enabled"] && local.argo-events["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argo-events-default-deny"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argo-events_allow_namespace" {
  count = local.argocd["create_ns"] && local.argo-events["enabled"] && local.argo-events["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argo-events-allow-namespace"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argocd"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argo-rollouts_default_deny" {
  count = local.argocd["create_ns"] && local.argo-rollouts["enabled"] && local.argo-rollouts["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argo-rollouts-default-deny"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argo-rollouts_allow_namespace" {
  count = local.argocd["create_ns"] && local.argo-rollouts["enabled"] && local.argo-rollouts["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argo-rollouts-allow-namespace"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argocd"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argo-workflows_default_deny" {
  count = local.argocd["create_ns"] && local.argo-workflows["enabled"] && local.argo-workflows["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argo-workflows-default-deny"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argo-workflows_allow_namespace" {
  count = local.argocd["create_ns"] && local.argo-workflows["enabled"] && local.argo-workflows["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argo-workflows-allow-namespace"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argocd"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd-applicationset_default_deny" {
  count = local.argocd["create_ns"] && local.argocd-applicationset["enabled"] && local.argocd-applicationset["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argocd-applicationset-default-deny"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd-applicationset_allow_namespace" {
  count = local.argocd["create_ns"] && local.argocd-applicationset["enabled"] && local.argocd-applicationset["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argocd-applicationset-allow-namespace"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argocd"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd-image-updater_default_deny" {
  count = local.argocd["create_ns"] && local.argocd-image-updater["enabled"] && local.argocd-image-updater["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argocd-image-updater-default-deny"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd-image-updater_allow_namespace" {
  count = local.argocd["create_ns"] && local.argocd-image-updater["enabled"] && local.argocd-image-updater["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argocd-image-updater-allow-namespace"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argocd"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd-notifications_default_deny" {
  count = local.argocd["create_ns"] && local.argocd-notifications["enabled"] && local.argocd-notifications["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argocd-notifications-default-deny"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "argocd-notifications_allow_namespace" {
  count = local.argocd["create_ns"] && local.argocd-notifications["enabled"] && local.argocd-notifications["default_network_policy"] ? 1 : 0

  metadata {
    name      = "argocd-notifications-allow-namespace"
    namespace = "argocd"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argocd"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}