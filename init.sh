#!/bin/bash

##Initial AccesNet y ExtNet interfaces
sudo ovs-vsctl --if-exists del-br AccessNet
sudo ovs-vsctl --if-exists del-br ExtNet
sudo ovs-vsctl add-br AccessNet
sudo ovs-vsctl add-br ExtNet

##Create Docker images
echo "--------------------------------------"
echo "-----------Imagen de VyOS-------------"
echo "--------------------------------------"
sudo docker build -t vnf-vyos img/vnf-vyos
echo "--------------------------------------"
echo "------------Imagen de vclass----------"
echo "--------------------------------------"
sudo docker build -t vnf-img img/vnf-img

##Onboarding OSM (Instalacion de los descriptores)
#VNF packages
echo "--------------------------------------"
echo "     Subiendo el vnf-vcpe.tar.gz"
echo "--------------------------------------"
osm vnfd-create pck/vnf-vcpe.tar.gz
echo "--------------------------------------"
echo "     Subiendo el vnf-vclass.tar.gz"
osm vnfd-create pck/vnf-vclass.tar.gz
#NS packages
echo "--------------------------------------"
echo "     Subiendo el ns-vcpe.tar.gz"
echo "--------------------------------------"
osm nsd-create pck/ns-vcpe.tar.gz

##Instanciate vCPE
echo "--------------------------------------"
echo "     Instanciando vcpe-1"
echo "--------------------------------------"
osm ns-create --ns_name vcpe-1 --nsd_name vCPE --vim_account emu-vim 
echo "--------------------------------------"
echo "     Instanciando vcpe-2"
echo "--------------------------------------"
osm ns-create --ns_name vcpe-2 --nsd_name vCPE --vim_account emu-vim

sleep 30

##Lista de instancias creadas
echo "--------------------------------------"
echo "     Lista de instancias creadas"
echo "--------------------------------------"
osm ns-list

##Creacion del escenario de las redes residenciales
echo "--------------------------------------"
echo "     Levantando escenario home"
echo "--------------------------------------"
sudo vnx -f vnx/nfv3_home_lxc_ubuntu64.xml -t

##Creacion del escenario de Internet
echo "--------------------------------------"
echo "     Levantando escenario server"
echo "--------------------------------------"
sudo vnx -f vnx/nfv3_server_lxc_ubuntu64.xml -t

