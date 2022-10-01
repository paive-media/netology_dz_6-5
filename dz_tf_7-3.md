# Домашнее задание к занятию "7.3 Подъем инфраструктуры в Яндекс.Облаке"

 ---

### Задание 1. 

От заказчика получено задание: при помощи Terraform и Ansible, собрать виртуальную инфраструктуру и развернуть на ней Web-ресурс. 

В инфраструктуре нужна одна машина с ПО ОС Linux, 2 ядрами и 2 Гигабайтами оперативной памяти. 

Требуется установить nginx, залить при помощи ansible конфигурационные файлы nginx и Web-ресурса. 

Для выполнения этого задания требуется сгенирировать ssh ключ командой ssh-kengen. Добавить в конфигурацию terraform ключ в поле:

 metadata = {
    user-data = "${file("./meta.txt")}"
  }
 
 В файле meta прописать: 
 ```
 users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa  xxx
```

где xxx - это ключ из файла /home/"name_user"/.ssh/id_rsa.pub.
Примерная конфигурация terraform:
```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "xxx"
  cloud_id  = "xxx"
  folder_id = "xxx"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd87kbts7j40q5b9rpjr"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}
```
В конфигурации ansible:
1) указать внешний ip адресс машины ( полученный из output external_ip_address_vm_1)  в файл hosts
2) указать доступ в файле plabook *yml поля hosts
```
- hosts: 138.68.85.196
  remote_user: user
  tasks:
    - service:
        name: nginx
        state: started
      become: yes
      become_method: sudo
```

Провести тестирование. 


#### Этап 1 - Настройка CLI для Яндекс.Облака

Делал по [инструкции](https://cloud.yandex.ru/docs/cli/quickstart#install)

```sh
curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
yc init
yc config list
yc iam service-account list
yc iam key create …
yc config set service-account-key yc_key.json
yc config set cloud-id CLOUD_ID
yc config set folder-id FOLDER_ID
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

#### Этап 2 - Подготовка Terraform внутри Яндекс.Облака

Делал по [инструкции](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart)

**Файлы:**
[main.tf](https://github.com/paive-media/netology_dz_6-5/terraform/main.tf)
[meta.txt](https://github.com/paive-media/netology_dz_6-5/terraform/meta.txt)

Внутри папки `dz7-3/terraform`
```sh
terraform version
terraform validate
terrafomt fmt
terraform plan
terraform apply "tf_plan"
```
![task1 screen1-1](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_tf_7-3_screen1-1.png "terraform@yac result begin")
…
![task1 screen1-2](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_tf_7-3_screen1-2.png "terraform@yac result end")


#### Этап 3 - Донастройка созданной ВМ при помощи Ansible

**Файлы:**
[ansible.cfg](ansible/ansible.cfg)
[inventory.ini](https://github.com/paive-media/netology_dz_6-5/ansible/inventory.ini)
[playbook1_nginx2tf.yaml](https://github.com/paive-media/netology_dz_6-5/ansible/playbook1_nginx2tf.yaml)

Внутри папки `dz7-3/terraform/ansible`
```sh
sudo apt update
sudo apt install ansible -y
ansible --version
ansible-playbook playbook1_nginx2tf.yaml --syntax-check
ansible-playbook playbook1_nginx2tf.yaml
```
![task1 screen2](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_tf_7-3_screen2.png "ansible playbook result")


#### Этап 4 - Освобождение ресурсов Яндекс.Облака

Внутри папки `dz7-3/terraform`
```sh
terraform destoy
```


---
