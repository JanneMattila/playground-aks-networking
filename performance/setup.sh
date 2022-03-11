#!/bin/bash

cd performance/

# All the variables for the deployment
subscriptionName="AzureDev"
aadAdminGroupContains="janne''s"

aksName="myaksnetperf"
acrName="myacrnetperf0000010"
workspaceName="mynetperfworkspace"
vnetName="mynetperf-vnet"
subnetAks="aks-subnet"
identityName="myaksnetperf"
resourceGroupName="rg-myaksnetperf"
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

# Virtual Machine SKUs:
# https://docs.microsoft.com/en-us/azure/virtual-machines/ddv4-ddsv4-series#ddsv4-series
# Standard_D8ds_v4
# => Expected network bandwidth (Mbps): 4000

az aks create -g $resourceGroupName -n $aksName \
 --zones 1 \
 --max-pods 50 --network-plugin azure \
 --node-count 2 --enable-cluster-autoscaler --min-count 2 --max-count 3 \
 --node-osdisk-type "Ephemeral" \
 --node-vm-size "Standard_D8ds_v4" \
 --kubernetes-version 1.22.6 \
 --enable-addons monitoring \
 --enable-aad \
 --enable-managed-identity \
 --disable-local-accounts \
 --aad-admin-group-object-ids $aadAdmingGroup \
 --workspace-resource-id $workspaceid \
 --attach-acr $acrid \
 --load-balancer-sku standard \
 --vnet-subnet-id $subnetaksid \
 --assign-identity $identityid \
 --api-server-authorized-ip-ranges $myip \
 -o table

# Create secondary node pool and use "secure-subnet" for pods in it
nodepool2="nodepool2"
az aks nodepool add -g $resourceGroupName --cluster-name $aksName \
  --name $nodepool2 \
  --node-count 1 --enable-cluster-autoscaler --min-count 1 --max-count 2 \
  --node-osdisk-type "Ephemeral" \
  --node-vm-size "Standard_D8ds_v4" \
  --node-taints "usage=limitedaccess:NoSchedule" \
  --labels usage=limitedaccess \
  --max-pods 150

# az aks nodepool delete -g $resourceGroupName --cluster-name $aksName --name $nodepool2

sudo az aks install-cli

az aks get-credentials -n $aksName -g $resourceGroupName --overwrite-existing

kubectl get nodes
kubectl get nodes -o wide
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl get nodes --show-labels=true
kubectl get nodes -L agentpool,usage
kubectl get nodes -o custom-columns=NAME:'{.metadata.name}',REGION:'{.metadata.labels.topology\.kubernetes\.io/region}',ZONE:'{metadata.labels.topology\.kubernetes\.io/zone}'
kubectl get nodes -o=custom-columns="NAME:.metadata.name,ADDRESSES:.status.addresses[?(@.type=='InternalIP')].address,PODCIDRS:.spec.podCIDRs[*]"

############################################
#  ____            __
# |  _ \ ___ _ __ / _|
# | |_) / _ \ '__| |_
# |  __/  __/ |  |  _|
# |_|   \___|_|  |_|
# Tester web app demo
############################################

# Deploy all items from demos namespace
kubectl apply -f demos/namespace.yaml
kubectl apply -f demos/deployment.yaml
kubectl apply -f demos/service.yaml

kubectl get deployment -n demos
kubectl describe deployment -n demos

kubectl get pod -n demos
kubectl get pod -n demos -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'

kubectl get service -n demos
svc_ip=$(kubectl get service -n demos -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")
echo $svc_ip

curl $svc_ip
# <html><body>Hello there!</body></html>

pod1_ip=$(kubectl get pod -n demos -o jsonpath="{.items[0].status.podIP}")
echo $pod1_ip

pod2_ip=$(kubectl get pod -n demos -o jsonpath="{.items[1].status.podIP}")
echo $pod2_ip

pod3_ip=$(kubectl get pod -n demos -o jsonpath="{.items[3].status.podIP}")
echo $pod3_ip

# Connect to first pod
pod1=$(kubectl get pod -n demos -o name | head -n 1)
echo $pod1
kubectl get $pod1 -n demos -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'
kubectl exec --stdin --tty $pod1 -n demos -- /bin/sh

# Connect to second pod
pod2=$(kubectl get pod -n demos -o name | tail -n +2 | head -n 1)
echo $pod2
kubectl get $pod2 -n demos -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'
kubectl exec --stdin --tty $pod2 -n demos -- /bin/sh

# Connect to "n" pod
pod3=$(kubectl get pod -n demos -o name | tail -n +3 | head -n 1)
echo $pod3
kubectl get $pod3 -n demos -o custom-columns=NAME:'{.metadata.name}',NODE:'{.spec.nodeName}'
kubectl exec --stdin --tty $pod3 -n demos -- /bin/sh

#################
# Test scenarios
#################

hostname

# If not installed, then install
apk add --no-cache iperf3
apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ qperf==0.4.11-r0

# Start server in one of the pods
iperf3 -s
qperf

# Execute different tests
ip=10.244.0.7
iperf3 -c $ip
qperf $ip -vvs -t 10 tcp_bw tcp_lat

# Exit container shell
exit

# Wipe out the resources
az group delete --name $resourceGroupName -y
