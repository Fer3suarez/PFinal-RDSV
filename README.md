## DESCRIPCIÓN DEL PROYECTO

Se va a utilizar la plataforma de código abierto Open Source Mano (OSM) para profundizar en la orquestación de funciones de red virtualizadas. El escenario que se va a utilizar
está inspirado en la reconversión de las centrales locales a centros de datos que permiten, entre
otras cosas, reemplazar servicios de red ofrecidos mediante hardware específico y propietario
por servicios de red definidos por software sobre hardware de propósito general. Las funciones
de red que se despliegan en estas centrales se gestionan mediante una plataforma de
orquestación como OSM o XOS.
El servicio de red objeto de estudio es el servicio residencial de acceso a Internet. El router residencial desplegado en casa del usuario, hace de switch Ethernet / punto de acceso
WiFi, servidor DHCP, traducción de direcciones NAT y reenvío de datagramas IP. El objetivo del proyecto es estudiar como esas funciones pasarán a realizarse en la central local. El router residencial se sustituye por un equipo que llamaremos “Bridged
Residential Gateway (BRG)” que realiza la conmutación de nivel 2 del tráfico de los usuarios
entre la red residencial y la central local. El resto de las funciones (DHCP, NAT y router para
reenvío IP) se realizan en la central local aplicando técnicas de virtualización de funciones de
red (NFV), creando un servicio de CPE virtual (vCPE) gestionado mediante la plataforma de
orquestación. 

Se muestra también una visión global del escenario que se va a emular, con dos sistemas finales
hX1 y hX2 en casa del usuario, conectados al brgX que, a través de la red de acceso AccessNet
se conecta a su vez a la central local, donde el servicio de red vCPE se va a ofrecer a través de
dos VNF encadenadas:
- Una VNF:vclass, que permitiría clasificar el tráfico e implementar QoS en el acceso del
usuario a la red por medio de un controlador controlado por OpenFlow
- Una VNF:vcpe, que integrará las funciones de servidor DHCP, NAT y reenvío de IP.

El entorno utilizado para gestionar los servicios de red es OSM.
Desde la VNF vcpe se accedería a la red pública a través del router
r1. En el escenario, se colocarám dos servidores s1 y s2 para emular servidores en Internet. A su vez, r1
permitirá acceso a la Internet “real”
El escenario explicado se va a implementar para la práctica en una máquina Linux en VirtualBox,
que ya tiene instaladas todas las herramientas necesarias, entre ellas:
- el entorno de OSM, al que se accede a través de un navegador
- la infraestructura de NFV (NFVI), controlada por OSM, implementada mediante la
plataforma de emulación vim-emu1
, que permite la ejecución de las VNFs
empaquetadas en forma de contenedores Dockers
- la herramienta VNX, que se usará para emular los equipos de la red residencial, el
router r1 y los servidores s1 y s2
- Open vSwitch (ovs), que por un lado es la herramienta utilizada internamente en vimemu para implementar las interconexiones entre las VNFs, y por otro lado,
utilizaremos en el escenario para emular la red de acceso AccessNet, la red externa
ExtNet que da salida al router r1, y como conmutador de nivel 2 para la emulación del
bgrX.

Se utilizará la tecnología VXLAN para enviar encapsuladas en
datagramas UDP las tramas de nivel 2 que viajan entre brgX, VNF:vclass y VNF:vcpe. Para
permitir esta comunicación, tanto el brgX como VNF:vclass tendrán interfaces en AccessNet,
configuradas con direcciones IP del prefijo 10.255.0.0/24. La asignación de direcciones IP a
VNF:class y VNF:vcpe en la red que las interconecta (data_vl), está gestionada por OSM, y utiliza
direcciones IP del prefijo 192.168.100.0/24.


## TAREAS A REALIZAR

- Utilización de contenedor VyOS como router residencial (vCPE)
- Conectividad IPv4 desde la red residencial hacia Internet. Uso de
doble NAT: en vCPE y en r1
- Sustituir el switch de vclass por un conmutador controlado por
OpenFlow
- Gestión de la calidad de servicio en la red de acceso mediante la API
REST de Ryu controlando vclass
    - Para limitar el ancho de banda de bajada hacia la red residencial
- Despliegue para dos redes residenciales
- Todo automatizado mediante OSM y scripts
    - Incluyendo el on-boarding de NS/VNFs y la instanciación de NS mediante línea
    de comandos


## Escenario del proyecto
![Escenario final](https://github.com/Fer3suarez/PFinal-RDSV/blob/main/Escenario.png)


## PASOS PARA LA EJECUCION DEL ESCENARIO

1. Clonar repositorio

2. Comprobar los permisos de los scripts

    2.1 Ejecutando ls -l en la terminal
	```
	ls -l
	```

    2.2 En caso de no tener permisos ejecutar lo siguiente
	```
	chmod 777 *name.sh* *name.sh*
	```

3. Comprobar el estado de vimemu

    3.1 Ejecutar en la terminal
	```
	osm-check-vimemu
	```
    
    3.2 Si vimemu no est enabled, ejecutar en la terminal:
	```
	osm-restart-vimemu
	```

4. Ejecutar el script de inicializacion (Se abriran un total de 9 terminales)
	```
	./init.sh
	```

5. Ejecutar el script que configura las VNFs de cada red residencial
	```
	./vcpe-1.sh
	./vcpe-2.sh
	```

6. Asignar una direccin IP a cada host de cada red residencial y comprobar que se ha asignado correctamente. En hXX, root/xxxx 
	```
	ifconfig
	dhclient
	ifconfig
	```

7. Ejecutar el script de calidad de servicio en cada red residencial
	```
	./qos.sh vcpe-1
	./qos.sh vcpe-2
	```

8. Verificar conexiones entre hosts, calidad de servicio, conexion a Internet...

## PASOS PARA LA DESTRUCCION DEL ESCENARIO

1. Ejecutar el script que para los VNX
	```
	./stop-vnx.sh
	```

2. Ejecutar el script de eliminacin de las instancias
	```
	./destroy.sh vcpe-1
	./destroy.sh vcpe-2
	```



