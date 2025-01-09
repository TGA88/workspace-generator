# Use the same base image as your services
FROM liquibase/liquibase:4.28.0-alpine

WORKDIR /liquibase
# Copy the Liquibase configuration files
COPY liquibase/changelog.yaml /liquibase/changelog.yaml
COPY prisma /liquibase/prisma
# COPY liquibase.template.properties /liquibase/liquibase.properties

COPY liquibase/custom-entrypoint.sh /liquibase/generate_properties.sh

# Make the script executable
USER root
RUN chmod +x /liquibase/generate_properties.sh

ENTRYPOINT [ "/liquibase/generate_properties.sh" ]


##command for run in local

#command to build the container
# docker build -f ./lqb.Dockerfile . -t test-lqb

#command to run the container
# docker run --network <replace-with-docker-container-name> \
#   -e DATABASE_URL=jdbc:postgresql://<replace-with-docker-container-name>:5432/postgres \
#   -e DATABASE_USER=postgres\
#   -e DATABASE_PASSWORD=postgres\
#   -e DATABASE_SCHEMA=FOS_PSC\
#   -e LQB_COMMAND="update"\
#   test-lqb