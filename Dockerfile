FROM sonatype/nexus3

COPY . /scripts
RUN chmod +x /scripts/*

ENV ADMIN_PASSWORD="admin123"

HEALTHCHECK --start-period=60s --interval=15s --timeout=15s --retries=3 \
  CMD /scripts/health.sh || exit

CMD ["sh", "-c", "/scripts/start.sh"]
