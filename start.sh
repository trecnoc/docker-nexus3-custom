#!/usr/bin/env bash

wait-for-nexus() {
  until $(curl --output /dev/null --silent --head --fail http://localhost:8081/service/rest/v1/status/writable); do
    printf '.'
    sleep 5
  done
  printf '\n'
}

# Used for the health check
touch /tmp/starting_nexus

# First start will create all the required conf and data directory
/opt/sonatype/nexus/bin/nexus start > /dev/null
printf "Waiting for Nexus to start and initialize the CONF and DATA directories"
wait-for-nexus

printf "Enabling Scripting"
/opt/sonatype/nexus/bin/nexus stop > /dev/null
echo "nexus.scripts.allowCreation=true" >> /nexus-data/etc/nexus.properties
/opt/sonatype/nexus/bin/nexus start > /dev/null
wait-for-nexus

if [ -z "${ADMIN_PASSWORD}" ]
then
  ADMIN_PASSWORD=admin123
fi

ADMIN_PASSWORD_FILE=/nexus-data/admin.password
if test -f "${ADMIN_PASSWORD_FILE}"; then
  printf "Fetching current admin password and resetting to provided value\n"
  CURRENT_ADMIN_PASSWORD=$(cat ${ADMIN_PASSWORD_FILE})
  curl -s --user admin:${CURRENT_ADMIN_PASSWORD} -X PUT "http://localhost:8081/service/rest/beta/security/users/admin/change-password" \
    -H "accept: application/json" \
    -H "Content-Type: text/plain" \
    -d "${ADMIN_PASSWORD}"
fi

printf "Creating 'nexus-test' raw repository\n"
cat <<EOF >/tmp/raw.json
{
  "name": "nexus-test-repo",
  "type": "groovy",
  "content": "repository.createRawHosted('nexus-test')"
}
EOF
chmod 666 /tmp/raw.json
jsonFile=/tmp/raw.json
curl -s -u admin:${ADMIN_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/rest/v1/script/' -d @$jsonFile > /dev/null
curl -s -X POST -u admin:${ADMIN_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/rest/v1/script/nexus-test-repo/run" > /dev/null

printf "Restarting the server in 'exec' mode\n"

/opt/sonatype/nexus/bin/nexus stop > /dev/null

# Remove staring health check file
rm /tmp/starting_nexus

exec /opt/sonatype/nexus/bin/nexus run
