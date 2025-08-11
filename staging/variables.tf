variable "ecs_apps" {
  description = "Map of apps to deploy in this environment"
  type = map(object({
    repo          = string
    cluster_name  = string
    service_name  = string
    image_tag     = string
    secrets       = optional(map(string), {})
  }))
}

