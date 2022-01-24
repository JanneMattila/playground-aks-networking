#!/bin/bash

cd subnet-example/

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
subnetSecure="secure-subnet"
identityName="myaksnetworking"
resourceGroupName="rg-myaksnetworking"
location="westeurope"

# Login and set correct context
az login -o table
az account set --subscription $subscriptionName -o table

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
subscriptionID=$(az account show -o tsv --query id)
resourcegroupid=$(az group create -l $location -n $resourceGroupName -o table --query id -o tsv)
echo $resourcegroupid

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

subnetdefaultid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name default-subnet --address-prefixes 10.1.0.0/20 \
  --query id -o tsv)
echo $subnetdefaultid

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

subnetsecureid=$(az network vnet subnet create -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetSecure --address-prefixes 10.5.0.0/24 \
  --query id -o tsv)
echo $subnetsecureid

# Create network security group
# - Assign it to 'secure-subnet' subnet
# - Deny traffic coming from 'pod-subnet' subnet
nsg="nsg-secure-subnet"
nsgrule1="rule1"
az network nsg create -n $nsg -g $resourceGroupName
az network nsg rule create --nsg-name $nsg -g $resourceGroupName \
  -n $nsgrule1 --priority 1000 \
  --source-address-prefixes 10.3.0.0/24 \
  --destination-address-prefixes '*' \
  --destination-port-ranges '*' \
  --access Deny \
  --description "Deny access from 'pod-subnet'"
az network vnet subnet update -g $resourceGroupName --vnet-name $vnetName \
  --name $subnetSecure --network-security-group $nsg

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

# Note: In our setup we want to create load balancer
# to separate subnet "internal-subnet" and that requires
# additional access rights to AKS identity:
az role assignment create \
  --role "Network Contributor" \
  --assignee-object-id $identityobjectid \
  --assignee-principal-type ServicePrincipal \
  --scope $vnetid

# Create secondary node pool and use "secure-subnet" for pods in it
nodepool2="nodepool2"
az aks nodepool add -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool2 \
  --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 2 \
  --node-osdisk-type "Ephemeral" \
  --node-vm-size "Standard_D8ds_v4" \
  --node-taints "usage=limitedaccess:NoSchedule" \
  --labels usage=limitedaccess \
  --pod-subnet-id $subnetsecureid \
  --max-pods 150

# az aks nodepool delete -g $resourceGroupName --cluster-name $aksName --name $nodepool2

sudo az aks install-cli

az aks get-credentials -n $aksName -g $resourceGroupName --overwrite-existing

kubectl get nodes -o wide
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl get nodes --show-labels=true
kubectl get nodes -L agentpool,usage

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
kubectl apply -f demos-external/service-shared.yaml

kubectl get deployment -n demos-external
kubectl describe deployment -n demos-external

# Check pod IP Addresses and verity that they are from 10.3.0.* = "pod-subnet":
kubectl get pod -n demos-external -o wide

external_pod=$(kubectl get pod -n demos-external -o name | head -n 1)
echo $external_pod

external_pod_ip=$(kubectl get pod -n demos-external -o jsonpath="{.items[0].status.podIP}")
echo $external_pod_ip

kubectl describe $external_pod -n demos-external

kubectl get service -n demos-external
# webapp-network-tester-external -> external IP is public IP
# webapp-network-tester-external-shared -> external IP is private IP in "internal-subnet"

external_svc_ip=$(kubectl get service -n demos-external -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $external_svc_ip

external_shared_svc_ip=$(kubectl get service -n demos-external -o jsonpath="{.items[1].status.loadBalancer.ingress[0].ip}")
echo $external_shared_svc_ip

curl $external_svc_ip
# -> <html><body>Hello there!</body></html>

# Deploy all items from demos-internal namespace
kubectl apply -f demos-internal/namespace.yaml
kubectl apply -f demos-internal/deployment.yaml
kubectl apply -f demos-internal/service.yaml
kubectl apply -f demos-internal/service-shared.yaml

kubectl get deployment -n demos-internal
kubectl describe deployment -n demos-internal

# Check pod IP Addresses and verity that they are from 10.5.0.* = "secure-subnet":
kubectl get pod -n demos-internal -o wide

internal_pod=$(kubectl get pod -n demos-internal -o name | head -n 1)
echo $internal_pod

internal_pod_ip=$(kubectl get pod -n demos-internal -o jsonpath="{.items[0].status.podIP}")
echo $internal_pod_ip

kubectl describe $internal_pod -n demos-internal

kubectl get service -n demos-internal
# webapp-network-tester-internal -> external IP is private IP in "pod-subnet"
# webapp-network-tester-internal-shared -> external IP is private IP in "internal-subnet"
kubectl describe service -n demos-internal

internal_svc_ip=$(kubectl get service -n demos-internal -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $internal_svc_ip

internal_shared_svc_ip=$(kubectl get service -n demos-internal -o jsonpath="{.items[1].status.loadBalancer.ingress[0].ip}")
echo $internal_shared_svc_ip

curl $internal_shared_svc_ip
# -> curl: (7) Failed to connect to 10.4.0.5 port 80: No route to host

# Verify setup
kubectl get pod -n demos-external -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'
# -> All pods should be in "nodepool1"
kubectl get pod -n demos-internal -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'
# -> All pods should be in "nodepool2"

# Access to "demos-internal" service via "demos-external" app:
# - "demos-external" pod is in "pod-subnet"
# - Service IP is in "pod-subnet"
echo "From $external_pod_ip ($external_svc_ip) to $internal_svc_ip - OK"
curl -X POST --data  "HTTP POST \"http://$internal_svc_ip/api/commands\"
INFO HOSTNAME" -H "Content-Type: text/plain" "$external_svc_ip/api/commands"
# -> Start: HTTP POST "http://10.2.0.6/api/commands"
# -> Start: INFO HOSTNAME
# HOSTNAME: webapp-network-tester-internal-99b6cbdfb-bc64j
# <- End: INFO HOSTNAME 1.36ms
# <- End: HTTP POST "http://10.2.0.6/api/commands" 5.44ms

# Access to "demos-internal" pod via "demos-external" app:
# - "demos-external" pod is in "pod-subnet"
# - Pod IP is in "secure-subnet"
echo "From $external_pod_ip ($external_svc_ip) to $internal_pod_ip - Timeout"
curl -X POST --data  "HTTP POST \"http://$internal_pod_ip/api/commands\"
INFO HOSTNAME" -H "Content-Type: text/plain" "$external_svc_ip/api/commands"
# -> Deny in network security group -> Timeout:
#
# -> Start: HTTP POST "http://10.5.0.17/api/commands"
# System.Threading.Tasks.TaskCanceledException: The request was canceled due to the configured HttpClient.Timeout of 100 seconds elapsing.
# <- End: HTTP POST "http://10.5.0.17/api/commands" 100003.10ms

# Access to "demos-internal" shared service in via "demos-external" app:
# - "demos-external" pod is in "pod-subnet"
# - Service IP is in "internal-subnet"
echo "From $external_pod_ip ($external_svc_ip) to $internal_shared_svc_ip - Timeout"
curl -X POST --data  "HTTP POST \"http://$internal_shared_svc_ip/api/commands\"
INFO HOSTNAME" -H "Content-Type: text/plain" "$external_svc_ip/api/commands"
# -> Start: HTTP POST "http://10.4.0.6/api/commands"
# -> Start: INFO HOSTNAME
# HOSTNAME: webapp-network-tester-internal-99b6cbdfb-bc64j
# <- End: INFO HOSTNAME 0.05ms
# <- End: HTTP POST "http://10.4.0.6/api/commands" 3.30ms

# External endpoint via "demo-external" app:
curl -X POST --data  "HTTP GET \"https://echo.jannemattila.com/pages/echo\"" -H "Content-Type: text/plain" "$external_svc_ip/api/commands"
# <clip>
# CLIENT-IP: 20.103.29.104:1024
# </clip>

# Get AKS network profile and effective outbound IPs --> Fetch IP Address
aksjson=$(az aks show -n $aksName -g $resourceGroupName -o json)
outboundipid=$(echo $aksjson | jq -r .networkProfile.loadBalancerProfile.effectiveOutboundIPs[0].id)
echo $outboundipid
publicipjson=$(az rest --method get --url "$outboundipid?api-version=2021-05-01" -o json)
ip=$(echo $publicipjson | jq -r .properties.ipAddress)
echo $ip
# 20.103.29.104

# Wipe out the resources
az group delete --name $resourceGroupName -y
