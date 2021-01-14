#!/bin/bash
echo "--------------------------------"
echo "      Arrancando vcpe-1"
echo "--------------------------------"
./vclass_start.sh vcpe-1 10.255.0.1 10.255.0.2
./vyos_start.sh vcpe-1 192.168.255.1 10.2.3.1




