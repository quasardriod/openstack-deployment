
- [Enable Openstack Command Completion](#enable-openstack-command-completion)
- [Identity Service(Keystone)](#identity-servicekeystone)
  - [Projects](#projects)
  - [Users and Groups](#users-and-groups)
- [Images(Glance)](#imagesglance)
- [Compute](#compute)
  - [Flavors](#flavors)
  - [SSH Keypair](#ssh-keypair)
  - [Security Groups](#security-groups)
  - [Servers(instances)](#serversinstances)
  - [Floating IPs](#floating-ips)
- [Networks](#networks)
  - [Create Private Network](#create-private-network)
  - [Create External Network](#create-external-network)
- [Additional Resources](#additional-resources)

## Enable Openstack Command Completion
```bash
$ openstack complete | sudo tee /etc/bash_completion.d/osc.bash_completion > /dev/null

$ source /etc/bash_completion.d/osc.bash_completion

# Or you can also put in bashrc

echo 'source /etc/bash_completion.d/osc.bash_completion' >> ~/.bashrc && source ~/.bashrc
```
## Identity Service(Keystone)
- Show current user configuration
```bash
$ openstack configuration show
```

### Projects
- Create Openstack Project
```bash
openstack project create k8s --domain default
```

### Users and Groups
```bash
# Create User
openstack user create --project k8s --password-prompt sumit

# Assign role to user, a role must be assigned to user to function properly
openstack role add --user sumit --project k8s admin

# Check role assigned to user
openstack role assignment list --user sumit

# Remove a role mapped to a user
openstack role remove --user sumit --project k8s admin
```
## Images(Glance)
```bash
# Download latest CentOS 9 stream Generic Cloud image
$ wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2

# Create Image
$ openstack image create --disk-format qcow2 \
--container-format bare --file CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2 \
centos9latest
```

## Compute
### Flavors
User with `admin` role case create and manage flavors.

```bash
# Create flavor
openstack flavor create --public m1.tiny --ram 512 --disk 5 --vcpus 1
```
### SSH Keypair
```bash
# Create SSH Keypair, below example will return private key. Save that in a file
$ openstack keypair create k8skey

# Get SSH public key from keypair, save that in a file
$ openstack keypair show k8skey --public-key
```

### Security Groups
```bash
# Permit ICMP (ping)
openstack security group rule create --proto icmp default

# Permit secure shell (SSH) access
openstack security group rule create --proto tcp --dst-port 22 default

# Allow Ingress to specific TCP port
openstack security group rule create --protocol tcp  --dst-port 6443 default
```
### Servers(instances)
```bash
# Create server
$ openstack server create --image centos9latest --flavor m1.tiny \
--security-group default --key-name k8skey --network k8spvtnet \
vm1

# Attach a floating ip
$ openstack server add floating ip kmaster 192.168.30.161
```

### Floating IPs
```bash
# Create floating ip
$ openstack floating ip create extnet

# To assign floating ip to user VM, user must create a router and set router external gateway
$ openstack router create k8s-router

# Add the self-service/private network subnet as an interface on the router:
$ openstack router add subnet router k8spvtsubnet

# Set a gateway on the provider/external network on the router
$ openstack router set k8s-router --external-gateway extnet

```

## Networks
- List the extensions of the system:
```bash
openstack extension list -c Alias -c Name --network
```
### Create Private Network
[Review](https://docs.openstack.org/install-guide/launch-instance-networks-selfservice.html) for detailed information on self-service/private network.

```bash
# Create Network
$ openstack network create k8spvtnet

# Create Subnet
openstack subnet create --network k8spvtnet \
  --dns-nameserver 8.8.8.8 --gateway 10.64.64.1 \
  --subnet-range 10.64.64.0/24 k8spvtsubnet
```

### Create External Network
External network must be created as `admin` user.

**NOTE:** You would need `physical_network` needed for `--provider-physical-network`. This is not applicable if you intend to use a local network type. `physical_network` must match one of the values defined under `bridge_mappings` in the `openvswitch_agent.ini`. By default it's `physnet1`. 

[Check](https://docs.openstack.org/install-guide/launch-instance-networks-provider.html) for more information.

Use below method to get `physical_network` name.
```bash
# On openstack Kolla Deployment
$ docker exec -it neutron_openvswitch_agent cat /etc/neutron/plugins/ml2/openvswitch_agent.ini
```

```bash
# Create Network
openstack network create  --share --external \
    --provider-physical-network physnet1 \
    --provider-network-type flat extnet

# Create subnet
openstack subnet create --network extnet \
    --allocation-pool start=192.168.30.150,end=192.168.30.170 \
    --dns-nameserver 8.8.8.8 --gateway 192.168.30.1 \
    --subnet-range 192.168.30.0/24 extsubnet

```

## Additional Resources
- [Default Roles](https://docs.openstack.org/keystone/latest/admin/service-api-protection.html)
- [Manage projects, users, and roles](https://docs.openstack.org/keystone/pike/admin/cli-manage-projects-users-and-roles.html)
- [Self-service network](https://docs.openstack.org/install-guide/launch-instance-networks-selfservice.html)
- [Identity concepts](https://docs.openstack.org/keystone/2024.1/admin/identity-concepts.html)
- [Security Groups](https://uh-iaas.readthedocs.io/security-groups.html)
- [Launch an instance](https://docs.openstack.org/install-guide/launch-instance.html#add-security-group-rules)