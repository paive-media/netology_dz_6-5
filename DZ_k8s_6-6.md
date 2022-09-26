# Домашнее задание к занятию "6.6. Kubernetes ч.2"

---
 

### Задание 1.

1. Создайте свой кластер с помощью kubeadm.
1. Установите любой понравившийся CNI плагин.
1. Добейтесь стабильной работы кластера.

*В качестве ответа пришлите скриншот результата выполнения команды `kubectl get po -n kube-system`*

![task1 screen](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_k8s_6-6_screen1.png "kubectl get po -n kube-system")


Через минуту `kubectl get pods` и `kubectl get po -n kube-system` перестают работать выдавая ошибку
```sh
[root@deb01:~# kubectl get po -n kube-system
 The connection to the server 10.129.0.20:6443 was refused - did you specify the right host or port?
```
 
 много раз делал `kubeadm reset` и потом даже смену сети на 10.244.0.0/16 для CNI flannel через `kubeadm init --pod-network-cidr "10.244.0.0/16"`

```sh
[root@deb01:~# kubectl get po -n kube-system
NAME                            READY   STATUS             RESTARTS         AGE
coredns-565d847f94-q4ztl        0/1     Pending            0                5m30s
coredns-565d847f94-vfkg9        0/1     Pending            0                5m30s
etcd-deb01                      1/1     Running            75 (3m29s ago)   4m38s
kube-apiserver-deb01            1/1     Running            83 (109s ago)    5m45s
kube-controller-manager-deb01   0/1     CrashLoopBackOff   5 (38s ago)      4m44s
kube-proxy-s6tzq                0/1     CrashLoopBackOff   3 (44s ago)      5m30s
kube-scheduler-deb01            0/1     CrashLoopBackOff   85 (10s ago)     4m51s
[root@deb01:~# kubectl get po -n kube-flannel
NAME                    READY   STATUS    RESTARTS       AGE
kube-flannel-ds-jr5ng   1/1     Running   4 (117s ago)   5m40s
```

никак не стартует контейнет **core-dns-…**
*прошу помощи, куда копать?*


---

### Задание 2.

Есть файл с деплоем:

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  replicas: 1
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: master
        image: bitnami/redis
        env:
         - name: REDIS_PASSWORD
           value: password123
        ports:
        - containerPort: 6379
```

1. Создайте Helm чарт.
1. Добавьте туда сервис.
1. Вынесите все нужные на Ваш взгляд параметры в `values.yaml`.
1. Запустите чарт в своем кластере и добейтесь его стабильной работы.

*Приведите вывод команды `helm get manifest <имя_релиза>` в качестве ответа*
