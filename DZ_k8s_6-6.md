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

При помощи правки конфига контроллера и демона-докера `/etc/docker/daemon.json` 
```sh
nano /etc/kubernetes/manifests/kube-controller-manager.yaml
```
```yaml
…
  containers:
  - command:
    - kube-controller-manager
!    - --allocate-node-cidrs=true
    - --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
    - --bind-address=127.0.0.1
!    - --cluster-cidr=10.244.0.0/16
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --cluster-name=kubernetes
```
```sh
systemctl restart kubelet
```
[источник](https://github.com/flannel-io/flannel/issues/728#issuecomment-425701657)


Получилось запустить кластер с сетевым плагином `flannel`
```sh
nano /etc/kubernetes/manifests/kube-controller-manager.yaml
```

```sh
kubectl get po --all-namespaces
```
![task1 screen2](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_k8s_6-6_screen2.png "kubectl get po -all-namespaces OK")


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

```sh


helm create mychart
cd mychart
rm -rf templates/*


rm Chart.yaml && nano Chart.yaml
--- 
apiVersion: v2
name: redis
description: A Helm chart for redis, test-chart for dz6-6
version: 0.1.0
type: application
maintainers:
  - name: Ivan Artemiev
appVersion: 1.0.0





rm templates/dz6-5_dep.yaml && nano templates/dz6-5_dep.yaml
--- 
apiVersion: apps/v1
kind: Deployment
metadata: 
  name: {{ .Chart.Name }}-dep
  labels: 
    app: {{ .Values.image.name }}
spec: 
  replicas: {{ .Values.replicaCount }}
  selector: 
    matchLabels: 
      app: {{ .Values.image.name }}
  template: 
    metadata: 
      labels: 
        app: {{ .Values.image.name }}
    spec: 
      containers: 
        - name: master
          env: 
            - name: REDIS_PASSWORD
              value: {{ .Values.config.password }}
          image: {{ .Values.image.repository }}/{{ .Values.image.name }}{{ .Values.image.version }}
          ports: 
            - containerPort: {{ .Values.config.port }}



rm templates/dz6-5_srv.yaml && nano templates/dz6-5_srv.yaml
---
apiVersion: v1
kind: Service
metadata: 
  name: {{ .Chart.Name }}-srv
  labels:
    app: {{ .Values.image.name }}
spec: 
  ports: 
    - 
      port: {{ .Values.config.port }}
      targetPort: {{ .Values.config.targetPort }}
  selector: 
    app: {{ .Values.image.name }}


rm values.yaml && nano values.yaml  
---
replicaCount: 1
    
image:
  repository: "bitnami"
  name: "redis"
  version: ""

config:
  port: 6379
  targetPort: 6379
  password: password123

```

![task1 screen3](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_k8s_6-6_screen3.png "helm deployed OK")
![task1 screen4](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_k8s_6-6_screen4.png "helm chart manifest OK")


