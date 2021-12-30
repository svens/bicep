# bicep

Sample Azure bicep-based cluster. This is side-project for
[UDP streaming performance tuning](https://github.com/svens/pal/tree/master/scripts/net-udp-tuning)
under Linux and Windows

It contains following virtual machines:
* udp-relay-linux: Debian/Linux machine hosting UDP relay server
* udp-relay-win: Windows Server 2022 machine hosting UDP relay server
* udp-client-X: 6 Debian/Linux machines hosting UDP relay clients

Cluster definition is specified in Bicep files in template/ directory:
* template/main.bicep: main module invoking modules that create actual resources
* template/net.bicep: networking resources (net and related security groups)
* template/vm.bicep: virtual machines (relays and clients)

For production, these templates should be used by automated tooling. For
side-project scope, there are bunch of helper scripts using Azure CLI for
manual control:
* `deploy`: create cluster deployment using Bicep templates
* `what-if`: run deployment What-If (i.e. show planned actions). Note: currently
  it is pretty much useless with module-based resources creation
* `validate`: validates whether template is a valid
* `ssh_config`: query every VM public IP address and print in .ssh/config
  format. It allows easily append new cluster config to existing ssh config
  file
* `passwd`: set new password for each VM in cluster
* `start`: start each VM in cluster
* `stop`: shut down each VM in cluster (billing still continues)
* `deallocate`: deallocate all VMs in cluster (stops billing for VMs)
