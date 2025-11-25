#!/bin/bash

# Install MariaDB using Helm

echo "Installing MariaDB with Helm..."

# Add Bitnami repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install MariaDB
helm install events-mariadb bitnami/mariadb \
  --set auth.rootPassword=rootpassword \
  --set auth.database=eventsdb \
  --set auth.username=eventsuser \
  --set auth.password=eventspass \
  --set primary.persistence.size=1Gi

echo "MariaDB installed!"
echo "Database: eventsdb"
echo "Username: eventsuser"
echo "Password: eventspass"
echo "Service: events-mariadb"

# Wait for MariaDB to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=mariadb --timeout=300s

echo "MariaDB is ready!"