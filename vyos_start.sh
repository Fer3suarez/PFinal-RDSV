#!/bin/bash

USAGE="
Usage:
    
vyos_start <vcpe_name> <vcpe_private_ip> <vcpe_public_ip> 
    being:
        <vcpe_name>: the name of the network service instance in OSM 
        <vcpe_private_ip>: the private ip address for the vcpe
        <vcpe_public_ip>: the public ip address for the vcpe (10.2.2.0/24)
"

if [[ $# -ne 3 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

VCPEPRIVIP="$2"
VCPEPUBIP="$3"

VNF1="mn.dc1_$1-1-ubuntu-1"
VNF2="mn.dc1_$1-2-ubuntu-1"

ETH11=`sudo docker exec -it $VNF1 ifconfig | grep eth1 | awk '{print $1}'`
ETH21=`sudo docker exec -it $VNF2 ifconfig | grep eth1 | awk '{print $1}'`
IP11=`sudo docker exec -it $VNF1 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`
IP21=`sudo docker exec -it $VNF2 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

sudo docker exec -ti $VNF2 /bin/bash -c "
source /opt/vyatta/etc/functions/script-template
configure
##Configuracion de VyOS
#Interfaz ethernet eth2 -> salida a la extNet
set interfaces ethernet eth2 address '$VCPEPUBIP/24'
set interfaces ethernet eth2 mtu 1400
#Interfaz vxlan vxlan2 
set interfaces vxlan vxlan2 address '$VCPEPRIVIP/24'
set interfaces vxlan vxlan2 remote '$IP11'
set interfaces vxlan vxlan2 mtu 1400
set interfaces vxlan vxlan2 port 8472
set interfaces vxlan vxlan2 vni 1
#Configuracion DHCP
set service dhcp-server shared-network-name 'LAN1' authoritative
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 default-router '$VCPEPRIVIP' 
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 dns-server '$VCPEPRIVIP'
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 domain-name 'vyos.net'
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 lease '86400'
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 range 0 start '192.168.255.9'
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 range 0 stop '192.168.255.254'
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H11 ip-address 192.168.255.5
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H11 mac-address 00:00:00:00:01:01
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H12 ip-address 192.168.255.6
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H12 mac-address 00:00:00:00:01:02
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H21 ip-address 192.168.255.7
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H21 mac-address 00:00:00:00:02:01
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H22 ip-address 192.168.255.8
set service dhcp-server shared-network-name 'LAN1' subnet 192.168.255.0/24 static-mapping DHCP-H22 mac-address 00:00:00:00:02:02
#Configuracion Nat en vCPE
set nat source rule 100 outbound-interface eth2
set nat source rule 100 source address '192.168.255.0/24'
set nat source rule 100 translation address masquerade
#Configuracion ruta por defecto
set protocols static route 0.0.0.0/0 next-hop 10.2.3.254 distance '1'

set interface ethernet eth0 disable
commit
save
exit
"


