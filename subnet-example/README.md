# Subnet example

![Network isolation using subnets](https://user-images.githubusercontent.com/2357647/150771670-3e52b310-7dba-42aa-8ecb-88b8d8b798bc.png)

This example uses Azure Virtual Network and subnets for networking isolation.

If uses following feature: [Dynamic allocation of IPs and enhanced subnet support](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni#dynamic-allocation-of-ips-and-enhanced-subnet-support)
to split different node pools to separate subnets.
This gives the benefit of using vnet capabilities e.g., Network Security Groups (NSGs)
for controlling the traffic between subnets.
