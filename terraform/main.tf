terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  zone = "ru-central1-b"
}


resource "yandex_compute_instance" "tfvm01" {
  name                      = "terraform1"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    mode = "READ_WRITE"
    initialize_params {
      image_id = "fd8le2jsge1bop4m18ts"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.tfsubnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
    ssh-keys  = "artemiev:${file("~/.ssh/id_ed25519.pub")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt full-upgrade -y",
      "sudo apt install ansible -y",
      "sudo apt install git -y",
      "sudo apt install atop -y",
      "sudo apt install ca-certificates curl gnupg lsb-release -y",
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian   $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update",
      "sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y"
    ]
    connection {
      type        = "ssh"
      user        = "artemiev"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.network_interface[0].nat_ip_address
    }
  }

  # provisioner "local-exec" {
  #   # command = "ansible-playbook -i '${self.network_interface[0].nat_ip_address},'  --private-key '${file("~/.ssh/id_ed25519")}' -b"
  #   command = "ansible all -m apt -a \"name=nginx state=latest update_cache=yes\" -b"
  # }

  scheduling_policy {
    preemptible = true
  }

}

resource "yandex_vpc_network" "tfnet-1" {
  name = "yanet01"
}

resource "yandex_vpc_subnet" "tfsubnet-1" {
  name           = "tfsubnet01"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.tfnet-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_tfvm_1" {
  value = yandex_compute_instance.tfvm01.network_interface.0.ip_address
}
output "external_ip_address_tfvm_1" {
  value = yandex_compute_instance.tfvm01.network_interface.0.nat_ip_address
}
