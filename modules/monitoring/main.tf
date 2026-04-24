# modules/monitoring/main.tf
#
# Creamos una alerta que nos avisa si la migración de una VM falla.


resource "google_monitoring_alert_policy" "migration_error" {
project = var.project_id
display_name = "Error en migracion de VM"
combiner = "OR"
enabled = true
conditions {
  display_name = "Error de replicacion detectado"
  condition_matched_log {
    filter  = "resource.type=\"vmmigration.googleapis.com/Source\" AND severity>=ERROR"
  }
}

alert_strategy {
  notification_rate_limit {
    period = "300s"
  }
}
    
}

