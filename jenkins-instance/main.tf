# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_service_account" "jenkins_sa" {
  account_id   = "jenkins-sa"
  display_name = "Jenkins Service Account"
}

resource "google_project_iam_member" "jenkins_sa_compute_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer" # 필요한 권한으로 변경
  member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

resource "google_project_iam_member" "jenkins_sa_compute_networkadmin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
}

resource "google_compute_network" "vpc_network" {
  name                    = "jenkins-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_jenkins" {
  name    = "allow-jenkins"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "jenkins_server" {
  name         = "jenkins-server"
  machine_type = "e2-medium"
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
  service_account {
    email  = google_service_account.jenkins_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y jenkins
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
  EOF
}