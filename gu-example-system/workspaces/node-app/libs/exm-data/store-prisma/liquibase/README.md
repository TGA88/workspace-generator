# command 

# install liquibase in wsl ubuntu

# generate changelog
liquibase --defaultsFile=liquibase.properties generateChangeLog

# check status
liquibase --defaultsFile=liquibase.properties status

# command update
liquibase --defaultsFile=liquibase.properties update

# run this before the rollback command to inspect the raw SQL for potential issues.
liquibase rollback-sql

# run rollback must have --rollback in file. count in number of how much step to rollback
liquibase rollbackCount <number> ,liquibase rollback-count <number>
liquibase rollbackCount 1