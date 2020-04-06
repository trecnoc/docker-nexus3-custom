# nexus3-custom
Customized Nexus3 Docker image for running the Nexus Concourse integration tests

List of changes from the base sonatype/nexus3 image

* Admin password reset to the default or one provided using the `ENV ADMIN_PASSWORD=<new_password>`.
* A raw hosted repository is created with the name `nexus-test`
