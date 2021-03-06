#!/usr/bin/env bash

set -e
#simulate devstack-gate
sudo apt-get update -y
sudo apt-get install -y git openvswitch-switch
sudo ovs-vsctl add-br br-ex
sudo ifconfig br-ex 172.24.5.1/24
sudo ovs-vsctl add-port br-ex vxlan -- set Interface vxlan type=vxlan options:local_ip=192.168.0.10 options:remote_ip=192.168.0.20 options:dst_port=8888

sudo rm -rf /opt/stack
sudo mkdir -p /opt/stack
sudo chown vagrant /opt/stack

git clone https://github.com/openstack-dev/devstack
cd devstack
cp /vagrant/control.conf local.conf
shost=`grep -ri 'SERVICE_HOST=' local.conf | cut -f2 -d'='`
sed -i -e "1i[[local|localrc]]" \
    -e "s/ERROR_ON_CLONE=.*/ERROR_ON_CLONE=False/" \
    -e "s/$shost/192.168.0.10/" \
    local.conf
./stack.sh

tempest init ~/tempest
cp /opt/stack/new/tempest/etc/tempest.conf ~/tempest/etc
