FROM sonatype/nexus3

COPY . /scripts

ENV ADMIN_PASSWORD="admin123"

# Add a healtcheck with default options except for the start-period.
# The 90s is the amount of sleep we are running in the start.sh script

HEALTHCHECK --start-period=90s --interval=30s --timeout=30s --retries=3 \
  CMD curl -f http://localhost:8081/service/rest/v1/status/writable || exit

CMD ["sh", "-c", "/scripts/start.sh"]
