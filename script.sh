#!/bin/bash

# Enable exit on error
set -e

# Program name
PROGNAME="${0##*/}"

# Usage error message
usage () {
  echo "$PROGNAME: usage: $0 DATABASE_NAME DATABASE_PORT DATABASE_PASSWORD"
}

# Handler for validation errors
exit_with_error () {
  echo "$PROGNAME: error: $1"
  exit 1
}

[[ $# == 3 ]] || (usage ; exit_with_error "Invalid number of parameters")

DATABASE_NAME=$1
DATABASE_PORT=$2
DATABASE_PASSWORD=$3

# Validate variables 
[[ -n "$DATABASE_NAME" ]] \
  || exit_with_error "env variable 'DATABASE_NAME' not set"

[[ -n "$DATABASE_PORT" ]] && [[ "$DATABASE_PORT" =~ ^[0-9]+$ ]] \
  || exit_with_error "env variable 'DATABASE_PORT' invalid or not set (only numbers)"

[[ -n "$DATABASE_PASSWORD" ]] && (( ${#DATABASE_PASSWORD} > 8 )) \
  || exit_with_error "env variable 'DATABASE_PASSWORD' invalid or not set (min 8 characters)"

# Define database directory
DATABASE_DIRECTORY="/databases/$DATABASE_NAME"
DATABASE_DATA_DIRECTORY="$DATABASE_DIRECTORY/data"

# Create directory to hold the database data
[[ -d $DATABASE_DIRECTORY ]] || mkdir $DATABASE_DIRECTORY -p
[[ -d $DATABASE_DATA_DIRECTORY ]] || mkdir $DATABASE_DATA_DIRECTORY -p

# Add permissions to write to directory
chmod 777 $DATABASE_DIRECTORY
chmod 777 $DATABASE_DATA_DIRECTORY

# Run the container with env configuration
docker run \
  -e 'ACCEPT_EULA=Y' \
  -e "SA_PASSWORD=$DATABASE_PASSWORD" \
  -e 'MSSQL_PID=Express' \
  -p "$DATABASE_PORT:1433" \
  -v "/databases/$DATABASE_NAME/data:/var/opt/mssql" \
  --name "$DATABASE_NAME" \
  --restart always \
  -d mcr.microsoft.com/mssql/server:2019-latest
