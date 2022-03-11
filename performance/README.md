# Network performance

## Kubenet vs. Azure CNI

[Choose the appropriate network model](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network#choose-the-appropriate-network-model)

> Kubenet is ideal for ... Simple websites with low traffic.
> **For most production deployments, you should plan for and use Azure CNI networking.**

[Limitations & considerations for kubenet](https://docs.microsoft.com/en-us/azure/aks/configure-kubenet#limitations--considerations-for-kubenet)

> An additional hop is required in the design of kubenet, which adds minor latency to pod communication.

## Links

[What is Accelerated Networking?](https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview)

[Virtual machine network bandwidth](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput)

[Reduce latency with proximity placement groups](https://docs.microsoft.com/en-us/azure/aks/reduce-latency-ppg)

[Bandwidth/Throughput testing (NTTTCP)](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-bandwidth-testing)

[Test VM network latency](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-test-latency)
