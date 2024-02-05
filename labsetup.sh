#!/usr/bin/env bash

COURSEDIR=$PWD

# sudo setfacl -m user:ubuntu:rw /var/run/docker.sock

red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

source /home/ubuntu/.scvs.lst
# export KONG_LICENSE_DATA=$(cat /usr/local/kong/license.json)
export KONG_LICENSE_DATA=$(cat /etc/kong/license.json)

# COURSENAME=$(echo $STRIGO_CLASS_NAME | awk -F" " {'print $1'})
COURSEDIR="/home/ubuntu/$KONG_COURSE_ID"

# export KONG_ADMIN_API_URI=http://$STRIGO_RESOURCE_DNS:8001
# export KONG_ADMIN_GUI_URL=http://$STRIGO_RESOURCE_DNS:8002
# export KONG_PORTAL_GUI_HOST=$STRIGO_RESOURCE_DNS:8003
# export KONG_PORTAL_API_URL=http://$STRIGO_RESOURCE_DNS:8004

printf "\n${green}Bringing up Kong Gateway.${normal}\n"

cd installation
# docker compose -f docker-compose_Aras.yaml up -d
docker compose up -d

# # Not sure why we have to do this
# cd /tmp/edu-strigo-infra/docker
# docker compose up -d
# cd $COURSEDIR

printf "\n${green}Waiting for Gateway startup to finish.${normal}\n"

until curl --head localhost:8001 > /dev/null 2>&1; do sleep 1; done

printf "\n${green}Gateway is up.${normal}\n"

# printf "\n${red}Applying Enterprise License.${normal}\n"
# http --headers POST "localhost:8001/licenses" payload=@/usr/local/kong/license.json | grep HTTP

# printf "\n${red}Recreating Contral Plane.${normal}\n"
# docker-compose stop kong-cp; docker-compose rm -f kong-cp; docker-compose up -d kong-cp
# # sleep 8
# until curl --head localhost:8001 > /dev/null 2>&1; do sleep 1; done

# printf "\n${red}Checking Admin API.${normal}\n"
# curl -IsX GET localhost:8001 | grep Server

# printf "\n${red}Enabling the Developer Portal.${normal}\n"
# curl -siX PATCH localhost:8001/workspaces/default -d "config.portal=true" | grep HTTP

# printf "\n${green}Configuring decK.${normal}\n"
printf "\n${green}Testing deck.${normal}\n\n"

sed -i "s|KONG_ADMIN_API_URI|$KONG_ADMIN_API_URI|g" $COURSEDIR/installation/deck/deck.yaml
cp $COURSEDIR/installation/deck/deck.yaml ~/.deck.yaml
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
printf "\n${green}Completed Setting up Lab Environment.${normal}\n\n"

# echo "Kong Manager can be access on $KONG_ADMIN_GUI_URL"
