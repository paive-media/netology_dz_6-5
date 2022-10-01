# Домашнее задание к занятию "7.1. Ansible"

 ---

### Задание 1. 

Какие преимущества дает подход IAC?

- использовать легко читаемые текстовые файлы для описания состояний/дествий по настройке сетевой инфраструктуры и управления сервисов
- контроль версий описательных файлов/структур
- повторяемость на многих инстансах, многих запусках
- легкое распространение описательных файлов/структур
- помощь community 
- возможное использование шаблонов, переменных, условных ветвлений

---

### Задание 2 

1. Установите Ansible.
2. Настройте управляемые машины (виртуальные или физические, не менее двух).
3. Создайте файл инвентори. Предлагается использовать файл, размещенный в папке с проектом, а не файл инвентори по умолчанию.
4. Проверьте доступность хостов с помощью модуля ping.

**Файлы**
[ansible.cfg](ansible71/ansible.cfg)
[inventory.ini](ansible71/inventory.ini)

```sh
ansible yac_debs -m ping --list-hosts
ansible yac_debs -m ping
```
![task2 screen1-1](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen1-1.png "ansible ping list")
![task2 screen1-2](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen1-2.png "ansible ping")

 
---

### Задание 3 

Какая разница между параметрами forks и serial? 

**forks** - число машин на которых по партиям управляющий сервер запускает и дожидается выполнения задач, прежде чем перейти к выполнению на следующей партии машин. 

**serial** - число машин на которых по партиям управляющий сервер запускает и дожидается выполнения ВСЕХ задач последовательно (т.е. всего playbook), прежде чем перейти к выполнению всего playbook-а на следующей партии машин.

Разобрался [по статье1](https://medium.com/devops-srilanka/difference-between-forks-and-serial-in-ansible-48677ebe3f36) 
и [по статье2](https://habr.com/ru/company/redhatrussia/blog/650679/)


---

### Задание 4 

В этом задании мы будем работать с Ad-hoc коммандами.

1. Установите на управляемых хостах пакет, которого нет(любой).
2. Проверьте статус любого присутствующего на управляемой машине сервиса. 
3. Создайте файл с содержимым "I like Linux" по пути /tmp/netology.txt

```sh
ansible yac_debs -m apt -a "name=atop update_cache=yes" --private-key ~/.ssh/id_ed25519 -b

ansible yac_debs -m shell -a "service docker status" --private-key ~/.ssh/id_ed25519 -b

ansible yac_debs -m copy -a "content='Artemiev calling :) {{ ansible_host }}' dest=/tmp/netology.txt" --private-key ~/.ssh/id_ed25519 -b
ansible yac_debs -m shell -a "cat /tmp/netology.txt"
ansible yac_debs -m file -a "path=/tmp/netology.txt state=absent"
```

![task4 screen1](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen4-1.png "ansible atop")
![task4 screen2](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen4-2.png "ansible service status")
![task4 screen3](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen4-3.png "ansible file create")
![task4 screen4](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen4-4.png "ansible file read")
![task4 screen5](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen4-5.png "ansible file remove")
![task4 screen6](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_ans_7-1_screen4-6.png "ansible file read error")


---

### Задание 5

Напишите 3 playbook'a. При написании рекомендуется использовать текстовый редактор с подсветкой синтаксиса YAML.
Плейбуки должны: 
1. Скачать какой либо архив, создать папку для распаковки и распаковать скаченный архив. Например, можете использовать официальный сайт и зеркало Apache Kafka https://kafka.apache.org/downloads. При этом можно качать как исходный код, так и бинарные файлы (запакованные в архив), в нашем задании не принципиально.
2. Установить пакет tuned из стандартного репозитория вашей ОС. Запустить его как демон (конфигурационный файл systemd появится автоматически при установке). Добавить tuned в автозагрузку.
3. Изменить приветствие системы (motd) при входе на любое другое по вашему желанию. Пожалуйста, в этом задании используйте переменную для задания приветствия. Переменную можно задавать любым удобным вам способом.

*Приложите файлы с плейбуками и вывод выполнения.*

 ---

### Задание 6

Задание модифицировать playbook из 3 пункта 5 задания: 

Playbook должен в качестве приветствия установить ip адрес и hostname усправляемого хоста, пожелание хорошего дня системному администратору. 

*Приложите файл с модифицированным плейбуком и вывод выполнения.*

 ---

### Задание 7

Создайте playbook, который будет включать в себя одну, вами созданную роль.
Роль должна:

1. Установить веб сервер Apache на управляемые хосты.
2. Сконфигурировать файл index.html c выводом характеристик для каждого компьютера. Необходимо включить CPU, RAM, величину первого HDD, ip адрес.
3. Открыть порт 80 (если необходимо), запустить сервер и добавить его в автозагрузку.
4. Сделать проверку доступности веб сайта(ответ 200).

*Приложите архив с ролью и вывод выполнения.*
