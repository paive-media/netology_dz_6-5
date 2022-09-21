____

# Задание 1.

Запустите кубернетес локально, используя `k3s` или `minikube` на свой выбор. Добейтесь стабильной работы всех системных контейнеров.
В качестве ответа пришлите скриншот результата выполнения команды 
``sh
kubectl get po -n kube-system
``

![task1 screen](/assets/images/dz_k8s_6-5_screen1.png "kubectl get po -n kube-system")




# Задание 2.

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

Измените файл так, чтобы:
- redis запускался без пароля;
- создайте Service, который будет направлять трафик на этот Deployment;
- версия образа redis была зафиксирована на 6.0.13.

Запустите Deployment в своем кластере и добейтесь его стабильной работы.
Приведите ответ в виде получившегося файла.

` **nano dz6-5_dep.yaml** `
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata: 
  name: redis-dep
  labels: 
    app: redis
spec: 
  replicas: 1
  selector: 
    matchLabels: 
      app: redis
  template: 
    metadata: 
      labels: 
        app: redis
    spec: 
      containers: 
        - name: master
          env: 
            - name: ALLOW_EMPTY_PASSWORD
              value: "true"
          image: bitnami/redis:6.0.13
          ports: 
            - containerPort: 6379

```
` **nano dz6-5_srv.yaml** `
```yaml
---
apiVersion: v1
kind: Service
metadata: 
  name: redis-service
  labels:
    app: redis
spec: 
  ports: 
    - 
      port: 6379
      targetPort: 6379
  selector: 
    app: redis

```

```sh
kubectl apply -f dz6-5_dep.yaml
kubectl apply -f dz6-5_srv.yaml

kubectl get po
kubectl get service

```

![task2 screen](/assets/images/dz_k8s_6-5_screen2.png "kubectl redis dep+srv")


# Задание 3.

Напишите команды kubectl для контейнера из предыдущего задания:

- выполнения команды ps aux внутри контейнера;
```sh
kubectl exec -it redis-dep-666667f659-9zw2k -- bash
I have no name!@redis-dep-666667f659-9zw2k:/$ ps aux
```
- просмотра логов контейнера за последние 5 минут;
```sh
kubectl logs redis-dep-666667f659-9zw2k --since=5m
```

- проброса порта локальной машины в контейнер для отладки.
```sh
kubectl port-forward redis-dep-666667f659-9zw2k 8080:80
```

- удаления контейнера;
```sh
kubectl delete pod redis-dep-666667f659-9zw2k
```

