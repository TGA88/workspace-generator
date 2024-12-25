#!/bin/bash
set -e

# Check if COMMAND is set
if [ -z "$LQB_COMMAND" ]; then
  echo "Error: LQB_COMMAND is not set."
  exit 1
fi

# Run Liquibase with the provided command
liquibase \
  --url=$LQB_DATABASE_URL \
  --username=$LQB_DATABASE_USER \
  --password=$LQB_DATABASE_PASSWORD \
  --defaultSchemaName=$LQB_DATABASE_SCHEMA \
  --liquibaseSchemaName=$LQB_DATABASE_SCHEMA \
  --changeLogFile=/changelog.yaml \
  --contexts=$LQB_CONTEXT \
  $LQB_COMMAND
