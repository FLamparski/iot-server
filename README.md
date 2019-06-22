# My IoT Server setup

This is a `docker-compose` application that powers my IoT server. It comes with:

1. InfluxDB for storing and querying metrics
2. Node-RED for defining pipelines for processing messages from IoT and other devices
3. Grafana for displaying the information
4. Mosquitto as the MQTT broker
5. Portanier for managing the Docker environment

This assumes an Ubuntu-based distribution. There is a Vagrantfile that spins up a VM for testing
the setup.

## Prerequisites

You need to have docker, docker-compose, and telegraf installed. You can crib from the Vagrantfile
for the commands you should use - they should be good for any Ubuntu flavour that's not too old,
too new, or too weird.

## Installation

Use `./setup.sh` to go through the install process:

```
cd iot-server
./setup.sh
```

## Post-install configuration

Note that `localhost` here means whatever server the iot-server app is running on.

### Grafana

Visit http://localhost:3000/ - you will be asked to log in. Enter username `admin` and password
`admin` - you will be prompted to change the password. From there on, you will need to configure
the InfluxDB data sources. (Can I stick the default into grafana.ini or setup.sh somehow?)

### Node-RED

Visit http://localhost:1880/ - you will need to configure the InfluxDB data sources/sinks.