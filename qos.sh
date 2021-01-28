#!/bin/bash

USAGE="
Usage:
    
qos <vcpe_name> 

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

sudo docker exec -it $VNF1 bin/bash -c "sed '/OFPFlowMod(/,/)/s/)/, table_id=1)/' usr/lib/python3/dist-packages/ryu/app/simple_switch_13.py > qos_simple_switch_13.py"

echo "--------------------------------------"
echo "Arrancando ryu-manager en $1"
echo "--------------------------------------"
sudo docker exec -d $VNF1 ryu-manager ryu.app.rest_qos ./qos_simple_switch_13.py ryu.app.rest_conf_switch

sleep 10

sudo docker exec -it $VNF1 ovs-vsctl set bridge br0 protocols=OpenFlow10,OpenFlow12,OpenFlow13
sudo docker exec -it $VNF1 ovs-vsctl set-fail-mode br0 secure
sudo docker exec -it $VNF1 ovs-vsctl set-manager ptcp:6632
sudo docker exec -it $VNF1 ovs-vsctl set-controller br0 tcp:127.0.0.1:6633
sudo docker exec -it $VNF1 ovs-vsctl set bridge br0 other-config:datapath-id=0000000000000001

sleep 10

sudo docker exec -it $VNF1 curl -X PUT -d '"tcp:127.0.0.1:6632"' http://localhost:8080/v1.0/conf/switches/0000000000000001/ovsdb_addr

sleep 10

sudo docker exec -it $VNF1 curl -X POST -d '{"port_name": "vxlan1", "type": "linux-htb", "max_rate": "12000000", "queues": [{"min_rate": "8000000"}, {"max_rate": "4000000"}]}' http://localhost:8080/qos/queue/0000000000000001

if [ $1 = "vcpe-1" ]; then
    	echo -e "\n---------------------------------------------------------"
    	echo -e "Configurando la QoS de la red residencial 1"
	echo -e "---------------------------------------------------------"
	echo -e "Configurando la QoS en h11"
	sudo docker exec -it $VNF1 curl -X POST -d '{"match": {"nw_dst": "192.168.255.5"}, "actions":{"queue": "0"}}' http://localhost:8080/qos/rules/0000000000000001
	echo -e "\nConfigurando la QoS en h12"
	sudo docker exec -it $VNF1 curl -X POST -d '{"match": {"nw_dst": "192.168.255.6"}, "actions":{"queue": "1"}}' http://localhost:8080/qos/rules/0000000000000001

elif [ $1 = "vcpe-2" ]; then
    	echo -e "\n---------------------------------------------------------"
    	echo -e "Configurando la QoS de la red residencial 2"
    	echo -e "---------------------------------------------------------"
	echo -e "Configurando la QoS en h21"
	sudo docker exec -it $VNF1 curl -X POST -d '{"match": {"nw_dst": "192.168.255.7"}, "actions":{"queue": "0"}}' http://localhost:8080/qos/rules/0000000000000001
	echo -e "\nConfigurando la QoS en h22"
	sudo docker exec -it $VNF1 curl -X POST -d '{"match": {"nw_dst": "192.168.255.8"}, "actions":{"queue": "1"}}' http://localhost:8080/qos/rules/0000000000000001
fi
echo -e "\n-------------------------------------------------------------"
echo "Reglas configuradas en $1"
sudo docker exec -it $VNF1 bin/bash -c "curl -X GET http://localhost:8080/qos/queue/0000000000000001 > $1.json"
echo -e "\n-------------------------------------------------------------"
sudo docker exec -it $VNF1 bin/bash -c "cat $1.json || jq"
echo -e "\n"






