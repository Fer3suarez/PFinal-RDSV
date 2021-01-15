#!/bin/bash

USAGE="
Usage:
    
destroy <vcpe_name> 

    being:
        <vcpe_name>: the name of the network service instance in OSM 
"

if [[ $# -ne 1 ]]; then
        echo ""       
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

VNF1="mn.dc1_$1-1-ubuntu-1"
VNF2="mn.dc1_$1-2-ubuntu-1"

sudo ovs-docker del-port AccessNet veth0 $VNF1
sudo ovs-docker del-port ExtNet eth2 $VNF2
echo "--------------------------------------"
echo "       Eliminando la instancia"
echo "--------------------------------------"
osm ns-delete $1
echo "------------------------------------------------------------------------"
echo "Si hay mas instancias creadas, en los siguientes pasos saldra un error"
echo "------------------------------------------------------------------------"
sleep 10
echo "--------------------------------------"
echo "       Eliminando el ns-vcpe.tar.gz"
echo "--------------------------------------"
osm nsd-delete vCPE
echo "--------------------------------------"
echo "       Eliminando el vnf-vclass.tar.gz"
echo "--------------------------------------"
osm vnfd-delete vclass
echo "--------------------------------------"
echo "       Eliminando el vnf-vcpe.tar.gz"
echo "--------------------------------------"
osm vnfd-delete vcpe

echo "-----------------------------"
echo "Lista de instancias creadas"
echo "-----------------------------"
osm ns-list



