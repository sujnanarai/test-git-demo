#!/usr/bin/env bash

# sudo setfacl -m user:ubuntu:rw /var/run/docker.sock

red=$(tput setaf 1)
normal=$(tput sgr0)

source ~/.envs

printf "\n${green}Setting up Kong Gateway Operations Lab Envrinment.${normal}\n"

cd ~/kong-gateway-operations/installation
docker-compose down

cd ~/
if [ -d "kong-gateway-operations" ]; then mv "kong-gateway-operations" "kong-gateway-operations.OLD"; fi
printf "\n${red}Cloning Kong Gateway Operations Repo under user home directory.${normal}\n"

# git clone https://github.com/kong-education/kong-gateway-operations.git ~/kong-gateway-operations
# cd ~/kong-gateway-operations/installation
# git checkout aws-ec2

# printf "\n${red}Copying SSL certificates to shared location.${normal}"
# cp -R ssl-certs /srv/shared
# printf "\n${red}Copying miscellaneous configuration to shared location.${normal}"
# mkdir -p /srv/shared/misc
# cp loopback.yaml /srv/shared/misc
# cp misc/kong_realm_template.json /srv/shared/misc
# cp misc/prometheus.yaml /srv/shared/misc
# cp misc/statsd.rules.yaml /srv/shared/misc
# printf "\n${red}Instantiating log files, accessibe at /srv/shared/logs/.${normal}"
# mkdir -p /srv/shared/logs
# touch $(grep '/srv/shared/logs/' docker-compose.yaml|awk '{print $2}'|xargs)
# chmod a+w /srv/shared/logs/*

printf "\n${red}Cleaning up previous instances in Docker.${normal}\n"
docker rm -f $(docker ps -a -q) > /dev/null 2>&1
docker volume rm $(docker volume ls -q) > /dev/null 2>&1
docker network rm -f kong-edu-net > /dev/null 2>&1

# printf "\n${red}Unsetting KONG_LICENSE_DATA environment variable.${normal}"
# if [ -z "KONG_LICENSE_DATA" ]; then unset KONG_LICENSE_DATA; fi

printf "\n${red}Bringing up Kong Gateway.${normal}\n"
docker-compose up -d
printf "\n${red}Waiting for Gateway startup to finish.${normal}"
# sleep 8

until curl --head localhost:8001 > /dev/null 2>&1; do sleep 1; done

printf "\n${red}Applying Enterprise License.${normal}\n"
http --headers POST "localhost:8001/licenses" payload=@/usr/local/kong/license.json | grep HTTP

printf "\n${red}Recreating Contral Plane.${normal}\n"
docker-compose stop kong-cp; docker-compose rm -f kong-cp; docker-compose up -d kong-cp
# sleep 8
until curl --head localhost:8001 > /dev/null 2>&1; do sleep 1; done

printf "\n${red}Checking Admin API.${normal}\n"
curl -IsX GET localhost:8001 | grep Server

printf "\n${red}Enabling the Developer Portal.${normal}\n"
curl -siX PATCH localhost:8001/workspaces/default -d "config.portal=true" | grep HTTP

printf "\n${red}Configuring decK.${normal}\n"
sed -i "s|KONG_ADMIN_API_URI|$KONG_ADMIN_API_URI|g" ~/kong-gateway-operations/installation/deck/deck.yaml
cp ~/kong-gateway-operations/installation/deck/deck.yaml ~/.deck.yaml
deck ping

# printf "\n${red}Copying the script to user path.${normal}\n"
# if [ ! -f "~/.local/bin/scram.sh" ]
# then
#   mkdir -p ~/.local/bin
#   cp ~/kong-gateway-operations/installation/reset-lab.sh ~/.local/bin/
#   source ~/.profile
# fi

# printf "\n${red}Displaying Gateway URIs${normal}\n"
# env | grep KONG | sort
printf "\n${red}Completed Setting up Kong Gateway Operations Lab Envrinment.${normal}\n\n"

echo "Kong Manager can be access on $KONG_ADMIN_GUI_URL"
