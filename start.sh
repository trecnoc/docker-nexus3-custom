#!/usr/bin/env bash

/opt/sonatype/nexus/bin/nexus start

echo "Sleeping to let the server start"
sleep 60

/opt/sonatype/nexus/bin/nexus stop

echo "Enabling Scripting"
echo "nexus.scripts.allowCreation=true" >> /nexus-data/etc/nexus.properties

echo "Restarting the server"
/opt/sonatype/nexus/bin/nexus start

echo "Sleeping to let the server start"
sleep 30

if [ -z "${ADMIN_PASSWORD}" ]
then
      ADMIN_PASSWORD=admin123
fi

ADMIN_PASSWORD_FILE=/nexus-data/admin.password
if test -f "${ADMIN_PASSWORD_FILE}"; then
    echo "Fetching current admin password and resetting to provided value"
    CURRENT_ADMIN_PASSWORD=$(cat ${ADMIN_PASSWORD_FILE})
    curl -s --user admin:${CURRENT_ADMIN_PASSWORD} -X PUT "http://localhost:8081/service/rest/beta/security/users/admin/change-password" \
	    -H "accept: application/json" \
	    -H "Content-Type: text/plain" \
	    -d "${ADMIN_PASSWORD}"
fi

echo "Create 'nexus-test' raw repository"
cat <<EOF >/tmp/raw.json
{
  "name": "nexus-test-repo",
  "type": "groovy",
  "content": "repository.createRawHosted('nexus-test')"
}
EOF
chmod 666 /tmp/raw.json
jsonFile=/tmp/raw.json
curl -s -u admin:${ADMIN_PASSWORD} --header "Content-Type: application/json" 'http://localhost:8081/service/rest/v1/script/' -d @$jsonFile
curl -s -X POST -u admin:${ADMIN_PASSWORD} --header "Content-Type: text/plain" "http://localhost:8081/service/rest/v1/script/nexus-test-repo/run"

echo -e "\nRestarting the server in 'exec' mode"
/opt/sonatype/nexus/bin/nexus stop
exec /opt/sonatype/nexus/bin/nexus run
