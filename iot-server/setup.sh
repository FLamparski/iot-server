#!/bin/bash

INSTALL_LOCATION=$(realpath $HOME/iot-server-app)
TELEGRAF_CONFIG_DIR=/etc/telegraf

INFLUXDB_DB=db0
INFLUXDB_USER=iot
INFLUXDB_USER_PASSWORD=IotServer
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=IotServer

echo_info () {
    echo "[info] " $@
}

prepare_directories () {
    echo_info "Creating app directory"
    mkdir $INSTALL_LOCATION

    echo_info "Creating directories"
    mkdir $INSTALL_LOCATION/grafana \
          $INSTALL_LOCATION/influxdb \
          $INSTALL_LOCATION/mosquitto \
          $INSTALL_LOCATION/node-red \
          $INSTALL_LOCATION/portainer
}

prepare_docker_compose () {
    echo_info "Preparing docker-compose app"
    cat docker-compose.template.yml | sed "s;\\\$INSTALL_LOCATION;$INSTALL_LOCATION;" > docker-compose.yml
}

setup_influx () {
    echo_info "Setting up InfluxDB"
    docker run --rm influxdb influxd config > $INSTALL_LOCATION/influxdb/influxdb.conf
    docker run --rm \
      -e INFLUXDB_DB=$INFLUXDB_DB -e INFLUXDB_ADMIN_ENABLED=true \
      -e INFLUXDB_ADMIN_USER=$INFLUXDB_ADMIN_USER -e INFLUXDB_ADMIN_PASSWORD=$INFLUXDB_ADMIN_PASSWORD \
      -e INFLUXDB_USER=$INFLUXDB_USER -e INFLUXDB_USER_PASSWORD=$INFLUXDB_USER_PASSWORD \
      -v $INSTALL_LOCATION/influxdb:/var/lib/influxdb \
      -v $INSTALL_LOCATION/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf \
      influxdb /init-influxdb.sh
}

do_install () {
    prepare_directories
    prepare_docker_compose

    echo_info "Building docker-compose app"
    docker-compose build

    setup_influx

    echo_info "Setting up Mosquitto"
    cp $PWD/mosquitto.sample.conf $INSTALL_LOCATION/mosquitto/mosquitto.conf

    echo_info "Setting up Grafana"
    touch $INSTALL_LOCATION/grafana/grafana.ini

    echo_info "Setting up Node-RED"
    # TODO: bcrypt -> install template

    echo_info "Done; run 'docker-compose up' to verify and 'docker-compose up -d' to daemonize"
}

print_settings () {
    echo_info "Setting up with following settings:"
    echo "Install location:" $INSTALL_LOCATION
    echo "InfluxDB admin user:" $INFLUXDB_ADMIN_USER
    echo "InfluxDB admin password:" $INFLUXDB_ADMIN_PASSWORD
    echo "InfluxDB user:" $INFLUXDB_USER
    echo "InfluxDB password:" $INFLUXDB_USER_PASSWORD
    echo "InfluxDB initial database:" $INFLUXDB_DB
}

print_settings
do_install