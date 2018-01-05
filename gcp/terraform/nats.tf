// NAT Primary
resource "google_compute_instance" "nat-gateway-pri" {
  name           = "${var.env_name}-nat-gateway-pri"
  machine_type   = "n1-standard-4"
  zone           = "${element(var.zones, 1)}"
  can_ip_forward = true
  tags           = ["${var.env_name}-nat-instance", "nat-traverse"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1404-trusty-v20160610"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet-infra-public.name}"

    access_config {
      // Ephemeral
    }
  }

  metadata_startup_script = <<EOF
#! /bin/bash
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
}

resource "google_compute_route" "nat-primary" {
  name                   = "${var.env_name}-nat-pri"
  dest_range             = "0.0.0.0/0"
  network                = "${google_compute_network.infra-virt-net.name}"
  next_hop_instance      = "${google_compute_instance.nat-gateway-pri.name}"
  next_hop_instance_zone = "${element(var.zones, 1)}"
  priority               = 800
  tags                   = ["${var.env_name}"]
}
