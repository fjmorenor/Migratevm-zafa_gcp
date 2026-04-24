resource "google_compute_firewall" "deny_all" {
    name = "deny-all-ingress"
    project = var.project_id
    network = var.network_id
    direction = "INGRESS"
    priority = 65534

    deny {
      protocol = "all"
    }
    source_ranges = [ "0.0.0.0/0" ]
}


resource "google_compute_firewall" "allow_iap_ssh" {
    name = "allow-iap-ssh"
    project = var.project_id
    network = var.network_id
    direction = "INGRESS"
    priority = 1000

    allow {
      protocol = "tcp"
      ports = [ "22" ]
    }
    source_ranges = [ "35.235.240.0/20" ]
    target_tags = [ "iap-ssh" ]
    
}

resource "google_compute_firewall" "allow_internal" {
    name = "allow-internal"
    project = var.project_id
    network = var.network_id
    direction = "INGRESS"
    priority = 1000

    allow {
      protocol = "tcp"
    }
    allow {
      protocol = "udp"
    }

    allow {
      protocol = "icmp"
    }

    source_ranges = [ "10.0.0.0/8" ]
    
}


resource "google_compute_firewall" "allow_grafana" {
    name = "allow-grafana"
    project = var.project_id
    network = var.network_id
    direction = "INGRESS"
    priority = 1000

    allow {
      protocol = "tcp"
      ports = [ "3000" ]
    }
    source_ranges = [ "35.235.240.0/20" ]
    target_tags =["grafana"]    
}



