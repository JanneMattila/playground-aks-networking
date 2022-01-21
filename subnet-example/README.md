# Subnet example

This example uses Azure Virtual Network and subnets for networking isolation.

If uses following feature: [Dynamic allocation of IPs and enhanced subnet support (preview)](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#dynamic-allocation-of-ips-and-enhanced-subnet-support-preview)
to split different node pools to separate subnets.
This gives the benefit of using vnet capabilities e.g., Network Security Groups (NSGs)
for controlling the traffic between subnets.
