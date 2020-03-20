#!/bin/bash

# Enable exit on error
set -e

# Program name
PROGNAME="${0##*/}"

# Handler for validation errors
exit_with_error () {
  echo "$PROGNAME: error: $1"
  exit 1
}

# Load environment variable from file
source ./.env

# Validate variables 
[[ -n "$DATABASE_NAME" ]] \
  || exit_with_error "env variable 'DATABASE_NAME' not set"

[[ -n "$DATABASE_PASSWORD" ]] && (( ${#DATABASE_PASSWORD} > 8 )) \
  || exit_with_error "env variable 'DATABASE_PASSWORD' invalid or not set (min 8 characters)"

[[ -n "$DATABASE_PORT" ]] && [[ "$DATABASE_PORT" =~ ^[0-9]+$ ]] \
  || exit_with_error "env variable 'DATABASE_PORT' invalid or not set (only numbers)"

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
  -d mcr.microsoft.com/mssql/server:2019-latest