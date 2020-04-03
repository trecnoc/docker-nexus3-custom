FROM sonatype/nexus3

COPY . /scripts

ENV ADMIN_PASSWORD="admin123"
CMD ["sh", "-c", "/scripts/start.sh"]
