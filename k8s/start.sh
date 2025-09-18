#!/usr/bin/env bash

kubectl apply -f postgres-secret.yaml
kubectl apply -f postgres-statefulset.yaml
kubectl apply -f app-deployment.yaml
kubectl apply -f postgres-storage.yaml
kubectl apply -f secret.yaml

minikube service teamavail-service