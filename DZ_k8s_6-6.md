# Домашнее задание к занятию "6.6. Kubernetes ч.2"

---
 

### Задание 1.

1. Создайте свой кластер с помощью kubeadm.
1. Установите любой понравившийся CNI плагин.
1. Добейтесь стабильной работы кластера.

*В качестве ответа пришлите скриншот результата выполнения команды `kubectl get po -n kube-system`*

![task1 screen](https://github.com/paive-media/netology_dz_6-5/blob/main/dz_k8s_6-6_screen1.png "kubectl get po -n kube-system")


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
