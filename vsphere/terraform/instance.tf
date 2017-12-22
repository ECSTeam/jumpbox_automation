resource "vsphere_virtual_machine" "jumpbox" {
  name                          = "${var.vm-name}"
  resource_pool_id              = "${data.vsphere_resource_pool.pool.id}"
  datastore_id                  = "${data.vsphere_datastore.ds.id}"
  num_cpus                      = "${var.vm-cpu}"
  num_cores_per_socket          = "${var.vm-cores}"
  memory                        = "${var.vm-memory}"
  folder                        = "${var.vm-folder}"
  guest_id                      = "${data.vsphere_virtual_machine.template.guest_id}"
  wait_for_guest_net_timeout    = "5"
  shutdown_wait_timeout         = "3"

  network_interface {
    network_id    = "${data.vsphere_network.network.id}"
    adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    name             = "${var.vm-name}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    linked_clone  = true

    customize {
      timeout     = "5"
      linux_options {
        host_name = "${var.vm-name}"
        domain    = "lab.ecsteam.local"
        time_zone = "America/Denver"
      }

      network_interface {

        #un-comment the ipv4 settings if you do not wish to use DHCP for network configuration

        #ipv4_address = "${var.vm-ipv4-addr}"
        #ipv4_netmask = "${var.vm-ipv4-netmask}"
      }

      #ipv4_gateway = "${var.vm-ipv4-gateway}"

    }
  }

  # Push Client Key to server
  # We disable host checking for this first ssh connection so that the jumpbox's identity can get stored into the known_hosts file without requiring user intervention
  provisioner "local-exec" {
    command = "sshpass -p ${var.ssh_password} ssh-copy-id -o StrictHostKeyChecking=no -i ${var.ssh_key_path}/${var.vm_client_cert} ${var.ssh_user}@${vsphere_virtual_machine.jumpbox.default_ip_address}"
  }

  # SSH Connection for all remote provisioner calls. This uses the client key and acts as additional validation that it was pushed correctly
  connection {
    type        = "ssh"
    user        = "${var.ssh_user}"
    private_key = "${file("${var.ssh_key_path}/${var.vm_client_cert}")}"
  }

  # Setup Jumpbox Server SSH keys for VM
  provisioner "remote-exec" {
      inline = [
        "ssh-keygen -t rsa -C ${var.vm-default-user}-${var.vm-name} -f ~/.ssh/${var.vm_svr_cert} -q -N ''"
      ]
  }

  #Retrieve Server Public SSH Key and place in local Directory
  provisioner "local-exec" {
    command = "scp -i ${var.ssh_key_path}/${var.vm_client_cert} ${var.ssh_user}@${vsphere_virtual_machine.jumpbox.default_ip_address}:~/.ssh/${var.vm_svr_cert}.pub ${var.ssh_key_path}."
  }


  # Upload Prepare Script
  provisioner "file" {
    source      = "${var.vm-prepare-file}"
    destination = "/tmp/prepare-jumpbox.sh"
  }

  # Setup jumpbox for IaaS
  provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/prepare-jumpbox.sh",
        "sudo /tmp/prepare-jumpbox.sh -u ${var.vm-user-list}"
      ]
    }
 } # End jumpbox resource
