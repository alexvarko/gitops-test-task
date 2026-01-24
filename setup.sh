#!/bin/bash

# colors
reset="\033[0m"
bold="\033[1m"
color_green="\033[32m"

dashes="----------------------------------------------------------------------------"



# Step 1: Start Minikube
printf "${bold}Starting Minikube...${reset}\n"
minikube start
printf "${bold}Minikube started!${reset}\n"
echo "${dashes}"

# Step 2: Add Helm Repositories
printf "${bold}Installing Flux Operator via Helm...${reset}\n"
helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator --namespace flux-system --create-namespace
printf "${bold}Flux Operator installed!${reset}"
echo "${dashes}"

# Step 3: Deploy FluxInstance
printf "${bold}Deploying Flux Instance...${reset}\n"
kubectl apply -f flux.yaml
printf "${bold}Flux Instance deployed!${reset}\n"
echo "${dashes}"

# Wait for Flux CRDs to be created/registered before proceeding
echo "Waiting for Flux CRDs to be created..."
timeout=120
interval=5
elapsed=0
while ! kubectl get crd | grep -E 'source.toolkit.fluxcd.io|helm.toolkit.fluxcd.io' >/dev/null 2>&1; do
  if [ $elapsed -ge $timeout ]; then
    echo "Timed out waiting for Flux CRDs after ${timeout}s"
    exit 1
  fi
  sleep $interval
  elapsed=$((elapsed + interval))
done
printf "${bold}Flux CRDs are present.${reset}\n"
echo "${dashes}"

# Step 4: Create Flux Resources for the repository
printf "${bold}Creating Flux resources for the repository...${reset}\n"
helm install flux-spam2000 ./charts/flux-spam2000 --namespace flux-system
printf "${bold}Flux resources created!${reset}\n"
echo "${dashes}"

# Step 5: Final Message
printf "${bold}${color_green}Setup completed successfully!${reset}\n"
printf "${bold}Wait for the automatic deployment of spam2000 and monitoring using FluxCD.${reset}\n"
echo "$dashes"

echo "To access the grafana, run the following command to get admin password:"
printf "${bold}kubectl get secret -n monitoring monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo${reset}\n"
echo "Then port-forward grafana service:"
printf "${bold}kubectl -n monitoring port-forward deployment/monitoring-grafana 3000:3000${reset}\n"
printf "${bold}Access grafana at http://localhost:3000 (username: admin)${reset}\n"
