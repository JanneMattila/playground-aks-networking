#!/bin/bash

# All the variables for the deployment
subscriptionName="AzureDev"
aadAdminGroupContains="janne''s"

aksName="myaksnetworking"
acrName="myacrnetworking0000010"
workspaceName="mynetworkingworkspace"
vnetName="mynetworking-vnet"
subnetAks="aks-subnet"
subnetPods="pod-subnet"
subnetInternal="internal-subnet"
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

subnetpodid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetPods --address-prefixes 10.3.0.0/24 \
  --query id -o tsv)
echo $subnetpodid

subnetinternalid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetInternal --address-prefixes 10.4.0.0/24 \
  --query id -o tsv)
echo $subnetinternalid

identityjson=$(az identity create --name $identityName --resource-group $resourceGroupName -o json)
identityid=$(echo $identityjson | jq -r .id)
identityobjectid=$(echo $identityjson | jq -r .principalId)
echo $identityid
echo $identityobjectid

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
 --enable-managed-identity \
 --disable-local-accounts \
 --aad-admin-group-object-ids $aadAdmingGroup \
 --workspace-resource-id $workspaceid \
 --attach-acr $acrid \
 --load-balancer-sku standard \
 --vnet-subnet-id $subnetaksid \
 --pod-subnet-id $subnetpodid \
 --assign-identity $identityid \
 --api-server-authorized-ip-ranges $myip \
 -o table

sudo az aks install-cli

az aks get-credentials -n $aksName -g $resourceGroupName --overwrite-existing

kubectl get nodes

# Note: In our setup we want to create load balancer
# to separate subnet "internal-subnet" and that requires
# additional access rights to AKS identity:
az role assignment create \
  --role "Network Contributor" \
  --assignee-object-id $identityobjectid \
  --assignee-principal-type ServicePrincipal \
  --scope $vnetid

############################################
#  _   _      _                      _
# | \ | | ___| |___      _____  _ __| | __
# |  \| |/ _ \ __\ \ /\ / / _ \| '__| |/ /
# | |\  |  __/ |_ \ V  V / (_) | |  |   <
# |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\
# Tester web app demo
############################################

# Deploy all items from demos-external namespace
kubectl apply -f demos-external/namespace.yaml
kubectl apply -f demos-external/deployment.yaml
kubectl apply -f demos-external/service.yaml

kubectl get deployment -n demos-external
kubectl describe deployment -n demos-external

# Check pod IP Addresses: 10.3.0.* from "pod-subnet":
kubectl get pod -n demos-external -o wide

pod1=$(kubectl get pod -n demos-external -o name | head -n 1)
echo $pod1

kubectl describe $pod1 -n demos-external
kubectl get service -n demos-external

ingressip=$(kubectl get service -n demos-external -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $ingressip

curl $ingressip
# -> <html><body>Hello there!</body></html>

# Deploy all items from demos-internal namespace
kubectl apply -f demos-internal/namespace.yaml
kubectl apply -f demos-internal/deployment.yaml
kubectl apply -f demos-internal/service.yaml

kubectl get deployment -n demos-internal
kubectl describe deployment -n demos-internal

pod2=$(kubectl get pod -n demos-internal -o name | head -n 1)
echo $pod2

kubectl describe $pod2 -n demos-internal
kubectl describe service -n demos-internal
kubectl get service -n demos-internal

ingressip2=$(kubectl get service -n demos-internal -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $ingressip2

curl $ingressip2
# -> curl: (7) Failed to connect to 10.4.0.4 port 80: No route to host

# Access to "demos-internal" via "demo-external" app:
curl -X POST --data  "HTTP GET \"http://$ingressip2\"" -H "Content-Type: text/plain" "$ingressip/api/commands"
# -> Start: HTTP GET "http://10.4.0.4"
# <html><body>Hello there!</body></html>
# <- End: HTTP GET "http://10.4.0.4" 418.42ms

# External endpoint via "demo-external" app:
curl -X POST --data  "HTTP GET \"https://echo.jannemattila.com/pages/echo\"" -H "Content-Type: text/plain" "$ingressip/api/commands"
# <clip>
# CLIENT-IP: 20.82.17.35:1024
# </clip>

# Get AKS network profile and effective outbound IPs --> Fetch IP Address
aksjson=$(az aks show -n $aksName -g $resourceGroupName -o json)
outboundipid=$(echo $aksjson | jq -r .networkProfile.loadBalancerProfile.effectiveOutboundIPs[0].id)
echo $outboundipid
publicipjson=$(az rest --method get --url "$outboundipid?api-version=2021-05-01" -o json)
ip=$(echo $publicipjson | jq -r .properties.ipAddress)
echo $ip

# Wipe out the resources
az group delete --name $resourceGroupName -y
