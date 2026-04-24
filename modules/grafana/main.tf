# modules/grafana/main.tf
#
# Crea una VM pequeña (e2-small) con Grafana instalado.
# Grafana nos permite ver las métricas de las VMs migradas en dashboards.
# La VM no tiene IP pública — se accede solo por tunnel IAP.

resource "google_compute_instance" "grafana" {
  name = "grafana"
  project = var.project_id
  machine_type = "e2-small"
  zone = var.zone
  tags = [ "iap-ssh","grafana" ]
  depends_on = [google_service_account_iam_member.terraform_can_use_grafana_sa]
    

    boot_disk {
      initialize_params {
        image = "debian-cloud/debian-12"
        size = 20
      }
      kms_key_self_link = var.disk_key_id
    }

    network_interface {
    # Usamos la subnet del host project (Shared VPC)
    subnetwork = var.subnet_self_link
    # Sin access_config = sin IP pública
  }

# Este script se ejecuta la primera vez que arranca la VM
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y wget curl
 
    # Añadir el repositorio oficial de Grafana
    wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" \
      > /etc/apt/sources.list.d/grafana.list
 
    apt-get update -y
    apt-get install -y grafana
 
    # Instalar los plugins para leer datos de GCP
    grafana-cli plugins install grafana-googlecloudmonitoring-datasource
    grafana-cli plugins install doitintl-bigquery-datasource
 
    systemctl enable grafana-server
    systemctl start grafana-server
  EOT
 
service_account {
    email  = google_service_account.grafana.email
    scopes = ["cloud-platform"]
  }
}

resource "google_service_account" "grafana" {
  project      = var.project_id
  account_id   = "sa-grafana"
  display_name = "Grafana Service Account"
}

resource "google_service_account_iam_member" "terraform_can_use_grafana_sa" {
  service_account_id = google_service_account.grafana.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:sa-terraform@lz-host-3effc8e5.iam.gserviceaccount.com"
}