#!/bin/bash
echo "--------------------------------"
echo "      Arrancando vcpe-2"
echo "--------------------------------"
./vclass_start.sh vcpe-2 10.255.0.3 10.255.0.4
./vyos_start.sh vcpe-2 192.168.255.2 10.2.3.2
