# Creamos un dataset en BigQuery y enviamos allí los logs de migración.
# Así podemos analizarlos con SQL cuando algo falle.

resource "google_bigquery_dataset" "migration_logs" {
    
    project = var.project_id
    dataset_id = "migration_logs"
    location = var.region
}

# El sink es el "cable" que lleva los logs a BigQuery
resource "google_logging_project_sink" "migration" {
    name = "migration-logs"
    project = var.project_id
    
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.migration_logs.dataset_id}"
  filter      = "resource.type=\"vmmigration.googleapis.com/Source\""

 
  unique_writer_identity = true

}

# Dar permiso al sink para escribir en BigQuery
resource "google_bigquery_dataset_iam_member" "sink_writer" {
    project = var.project_id
    dataset_id = google_bigquery_dataset.migration_logs.dataset_id
    role = "roles/bigquery.dataEditor"
    member = google_logging_project_sink.migration.writer_identity
    
}