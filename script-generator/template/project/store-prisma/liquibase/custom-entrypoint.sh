#!/bin/bash
set -e

# Check if COMMAND is set
if [ -z "$LQB_COMMAND" ]; then
  echo "Error: LQB_COMMAND is not set."
  exit 1
fi

# Run Liquibase with the provided command
liquibase \
  --url=$DATABASE_URL \
  --username=$DATABASE_USER \
  --password=$DATABASE_PASSWORD \
  --defaultSchemaName=$DATABASE_SCHEMA \
  --liquibaseSchemaName=$DATABASE_SCHEMA \
  --changeLogFile=/changelog.yaml \
  --contexts=$LQB_CONTEXT \
  $LQB_COMMAND
