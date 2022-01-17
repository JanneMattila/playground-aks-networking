#!/bin/bash

# All the variables for the deployment
subscriptionName="AzureDev"
aadAdminGroupContains="janne''s"

aksName="myaksnetworking"
acrName="myacrnetworking0000010"
workspaceName="mynetworkingworkspace"
vnetName="mynetworking-vnet"
subnetAks="AksSubnet"
identityName="myaksnetworking"
resourceGroupName="rg-myaksnetworking"
location="westeurope"

# Login and set correct context
az login -o table
az account set --subscription $subscriptionName -o table

subscriptionID=$(az account show -o tsv --query id)
resourcegroupid=$(az group create -l $location -n $resourceGroupName -o table --query id -o tsv)
echo $resourcegroupid

# Prepare extensions and providers
az extension add --upgrade --yes --name aks-preview

# Enable features
az feature register --namespace "Microsoft.ContainerService" --name "EnablePodIdentityPreview"
az feature register --namespace "Microsoft.ContainerService" --name "AKS-ScaleDownModePreview"
az feature register --namespace "Microsoft.ContainerService" --name "PodSubnetPreview"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/EnablePodIdentityPreview')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-ScaleDownModePreview')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/PodSubnetPreview')].{Name:name,State:properties.state}"
az provider register --namespace Microsoft.ContainerService

# Remove extension in case conflicting previews
# az extension remove --name aks-preview

acrid=$(az acr create -l $location -g $resourceGroupName -n $acrName --sku Basic --query id -o tsv)
echo $acrid

aadAdmingGroup=$(az ad group list --display-name $aadAdminGroupContains --query [].objectId -o tsv)
echo $aadAdmingGroup

workspaceid=$(az monitor log-analytics workspace create -g $resourceGroupName -n $workspaceName --query id -o tsv)
echo $workspaceid

vnetid=$(az network vnet create -g $resourceGroupName --name $vnetName \
  --address-prefix 10.0.0.0/8 \
  --query newVNet.id -o tsv)
echo $vnetid

subnetaksid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetAks --address-prefixes 10.2.0.0/20 \
  --query id -o tsv)
echo $subnetaksid

identityid=$(az identity create --name $identityName --resource-group $resourceGroupName --query id -o tsv)
echo $identityid

az aks get-versions -l $location -o table

# Note: for public cluster you need to authorize your ip to use api
myip=$(curl --no-progress-meter https://api.ipify.org)
echo $myip

# Note about private clusters:
# https://docs.microsoft.com/en-us/azure/aks/private-clusters

# For private cluster add these:
#  --enable-private-cluster
#  --private-dns-zone None

az aks create -g $resourceGroupName -n $aksName \
 --max-pods 50 --network-plugin azure \
 --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 2 \
 --node-osdisk-type "Ephemeral" \
 --node-vm-size "Standard_D8ds_v4" \
 --kubernetes-version 1.22.4 \
 --enable-addons monitoring \
 --enable-aad \
 --enable-azure-rbac \
 --enable-managed-identity \
 --enable-pod-identity \
 --disable-local-accounts \
 --aad-admin-group-object-ids $aadAdmingGroup \
 --workspace-resource-id $workspaceid \
 --attach-acr $acrid \
 --load-balancer-sku standard \
 --vnet-subnet-id $subnetaksid \
 --assign-identity $identityid \
 --api-server-authorized-ip-ranges $myip \
 -o table

sudo az aks install-cli

az aks get-credentials -n $aksName -g $resourceGroupName --overwrite-existing

# If using "--enable-azure-rbac" and you need to grant more access rights:
aksid=$(az aks show -g $resourceGroupName -n $aksName --query id -o tsv)
az role assignment create \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --assignee $aadAdmingGroup \
  --scope $aksid

kubectl get nodes

############################################
#  _   _      _                      _
# | \ | | ___| |___      _____  _ __| | __
# |  \| |/ _ \ __\ \ /\ / / _ \| '__| |/ /
# | |\  |  __/ |_ \ V  V / (_) | |  |   <
# |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\
# Tester web app demo
############################################

# Deploy all items from demos namespace
kubectl apply -f demos/namespace.yaml
kubectl apply -f demos/deployment.yaml
kubectl apply -f demos/service.yaml

kubectl get deployment -n demos
kubectl describe deployment -n demos

pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1

kubectl describe $pod1 -n demos
kubectl get service -n demos

ingressip=$(kubectl get service -n demos -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $ingressip

curl $ingressip
# -> <html><body>Hello there!</body></html>

# Wipe out the resources
az group delete --name $resourceGroupName -y
