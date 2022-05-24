#!/bin/bash

DOCKER_PATH=/Users/michaeltoriola/Projects/Resources/docker
SKELETON_PATH=$DOCKER_PATH/docker-ubuntu-skeleton
SKELETON_PATH_NGINX=$DOCKER_PATH/docker-ubuntu-nginx-skeleton
SITES_PATH=/Users/michaeltoriola/Projects/sites

#Declare env_data as associative array
declare -A env_data

#Set env_data array default values for arguments
env_data=(
  [DOMAIN]=${DOMAIN:-FALSE}
  [PORT]=${PORT:-18090}
  [DB_USERNAME]=${DB_USERNAME:-root}
  [DB_PASSWORD]=${DB_PASSWORD:-password}
  [DB_NAME]=${DB_NAME:-FALSE}
  [DB_PORT]=${DB_PORT:-13306}
  [SKELETON_PATH]=${SKELETON_PATH:-${SKELETON_PATH}}
  [SITES_PATH]=${SITES_PATH:-${SITES_PATH}}
  [HTTP_SERVER]=${HTTP_SERVER:-apache}
)

#Function to check if an array key exists
array_key_exists(){
  #Checks if arguments are entered the correct way
  if [ "$2" != in ]; then
    echo "Incorrect usage."
    echo "Correct usage: exists {key} in {array}"
    return
  fi
  #if array[key] ($3) is set, return setz
  #if array[key] ($3) is not set, return nothing
  eval '[ ${'"$3"'[$1]+set} ]'
}

get_os() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
      Linux*)     machine=Linux;;
      Darwin*)    machine=Mac;;
      CYGWIN*)    machine=Cygwin;;
      MINGW*)     machine=MinGw;;
      *)          machine="UNKNOWN:${unameOut}"
  esac
  echo "$machine"
}

escapeString() {
  escapedString=$(echo "$1" | sed "s/\//\\\\\//g")
  echo "$escapedString"
}

clone_skeleton_func() {
    if [ ! -d "${env_data[SITES_PATH]}" ]; then
      echo "Error, sites path not valid directory."
      return;
    fi

    if [ -d "${env_data[SITES_PATH]}/${env_data[DOMAIN]}" ]; then
      echo "Error, site directory already exists." "${env_data[SITES_PATH]}/${env_data[DOMAIN]}"
      return;
    fi

    cp -r "${env_data[SKELETON_PATH]}/" "${env_data[SITES_PATH]}/${env_data[DOMAIN]}"

    if [ ! -d "${env_data[SITES_PATH]}/${env_data[DOMAIN]}" ]; then
      echo "Error cloning skeleton";
      return;
    fi
    echo 1
}

replace_placeholders_func() {
  machine=$( get_os )
  if [ "$machine" = "Mac" ]; then
    sed -i '' -e "s/<site_name>/$(escapeString "${env_data[DOMAIN]}-${env_data[HTTP_SERVER]}")/g" \
    -e "s/<port>/$(escapeString "${env_data[PORT]}")/g" "${env_data[SITES_PATH]}/${env_data[DOMAIN]}/docker/docker-compose.yml"
    if [ ! "${env_data[DB_NAME]}" == "FALSE" ]; then
      sed -i '' -e "s/<db_name>/$(escapeString ${env_data[DB_NAME]})/g" "${env_data[SITES_PATH]}/${env_data[DOMAIN]}/docker/.env"
    fi
    echo 1
    return;
  elif [ "$machine" = "Linux" ]; then
    sed -i -e "s/<site_name>/$(escapeString "${env_data[DOMAIN]}-${env_data[HTTP_SERVER]}")/g" \
    -e "s/<port>/$(escapeString "${env_data[PORT]}")/g" "${env_data[SITES_PATH]}/${env_data[DOMAIN]}/docker/docker-compose.yml"
    if [ ! "${env_data[DB_NAME]}" == "FALSE" ]; then
      sed -i -e "s/<db_name>/$(escapeString ${env_data[DB_NAME]})/g" "${env_data[SITES_PATH]}/${env_data[DOMAIN]}/docker/.env"
    fi
    echo 1
    return;
  else
    echo 0
    return;
  fi
}

create_db_func() {
  if [ "${env_data[DB_NAME]}" == "FALSE" ]; then
    echo 2
    return;
  fi
  mysql --user ""${env_data[DB_USERNAME]}"" -p"${env_data[DB_PASSWORD]}" --host 127.0.0.1 --port "${env_data[DB_PORT]}" --execute "create database ${env_data[DB_NAME]}"
  echo 1
}

# Function to loop through all arguments
# and declare the argument as a variable/set the value in the env_data array
# containing the arguments value
while [ $# -gt 0 ]; do
  param="${1/--/}"
  if [[ $1 == *"--"* ]]; then
    declare $param="$2"
    env_data[$param]="$2"
    # echo $1 $2 // Optional to see the parameter:value result
  fi
  shift
done

if [ "${env_data[DOMAIN]}" == "FALSE" ]; then
  echo "Error, domain not set."
  exit 0;
fi

if [ "${env_data[HTTP_SERVER]}" == "nginx" ]; then
  env_data[SKELETON_PATH]=$SKELETON_PATH_NGINX
  env_data[SITES_PATH]="${env_data[SITES_PATH]}/nginx"
else 
  env_data[SKELETON_PATH]=$SKELETON_PATH
  env_data[SITES_PATH]="${env_data[SITES_PATH]}/apache"
fi

if [ ! -d "${env_data[SKELETON_PATH]}" ]; then
  echo "Error, skeleton path not valid directory."
  exit 0;
fi

clone_skeleton=$( clone_skeleton_func )
if [ ! "$clone_skeleton" == 1 ]; then
  echo "$clone_skeleton"
  echo "Skeleton clone error, exiting..."
  exit 0
fi

replace_placeholders=$( replace_placeholders_func )
if [ ! "$replace_placeholders" == 1 ]; then
  echo "Error replacing placeholders, exiting..."
  exit 0
fi

create_db=$( create_db_func )
if [ "$create_db" == 2 ]; then
  echo  "No db specified, skipping..."
else
  echo "Error creating db, exiting..."
  exit 0
fi

echo "Successfully generated site"
echo "Domain: ${env_data[DOMAIN]}"
if [ "$create_db" == 1 ]; then
  echo "DB: ${env_data[DB_NAME]}"
fi
echo "Site Path: ${env_data[SITES_PATH]}/${env_data[DOMAIN]}"