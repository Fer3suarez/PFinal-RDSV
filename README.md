# PASOS PARA LA EJECUCION DEL ESCENARIO

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

# PASOS PARA LA DESTRUCCION DEL ESCENARIO

1. Ejecutar el script que para los VNX
	```
	./stop-vnx.sh
	```

2. Ejecutar el script de eliminacin de las instancias
	```
	./destroy.sh vcpe-1
	./destroy.sh vcpe-2
	```



