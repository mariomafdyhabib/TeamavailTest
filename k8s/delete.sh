#!/usr/bin/env bash

kubectl delete -f postgres-secret.yaml
kubectl delete -f postgres-statefulset.yaml
kubectl delete -f app-deployment.yaml
kubectl delete -f postgres-storage.yaml
kubectl delete -f secret.yaml

minikube stop
