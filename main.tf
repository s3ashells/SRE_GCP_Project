// Create VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-subnet"
  ip_cidr_range =  var.subnet_cidr
  network       = "${var.name}-vpc"
  depends_on    = [google_compute_network.vpc]
  region        =   var.region
}
// VPC firewall configuration
resource "google_compute_firewall" "firewall" {
  name    = "${var.name}-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "8500", "8000"]
  }
}
// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}
resource "google_compute_instance" "consul" {
  name         = "consul-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata_startup_script = "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -; sudo apt-add-repository 'deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main';  sudo apt-get update && sudo apt-get install consul"

  metadata = {
    ssh-keys = "${var.ssh-username}:${file("~/.ssh/id_ed25519.pub")}"
  }

  network_interface {
    network = google_compute_network.vpc.name
    access_config {
     // Include this section to give the VM an external ip address
  }
  }
}
resource "google_compute_instance" "server" {
  name         = "server-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }
  metadata_startup_script = "sudo apt-get update; sudo apt-get install git-all; sudo apt-get -y upgrade; wget https://dl.google.com/go/go1.16.4.linux-amd64.tar.gz; tar -xvf go1.16.4.linux-amd64.tar.gz; sudo mv go /usr/local; export GOROOT=/usr/local/go; export GOPATH=$HOME/Projects/Proj1; export PATH=$GOPATH/bin:$GOROOT/bin:$PATH"
  
  metadata = {
    ssh-keys = "${var.ssh-username}:${file("~/.ssh/id_ed25519.pub")}"
  }
  hostname = "${var.hostname}"
  network_interface {
    network = google_compute_network.vpc.name
    access_config {
     // Include this section to give the VM an external ip address
  }
  }
}

resource "google_sql_database_instance" "master" {
  name = "${var.name}-database-instance"
  database_version = "POSTGRES_9_6"
  region       = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      private_network = google_compute_network.vpc.id
    }
  }
}

resource "google_sql_database" "database" {
  name      = "${var.name}-database"
  instance  = google_sql_database_instance.master.name
}

resource "google_sql_user" "users" {
  name     = var.sqluser
  instance = google_sql_database_instance.master.name
  password = var.sqlpassword
}
