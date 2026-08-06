FROM ubuntu:24.04

ARG WAZUH_VERSION=4.14.6-1

ENV DEBIAN_FRONTEND=noninteractive
ENV WAZUH_MANAGER=10.10.20.10
ENV WAZUH_AGENT_NAME=linux-target-01
ENV WAZUH_AGENT_GROUP=linux-servers

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        procps \
        iproute2 \
        netcat-openbsd \
        rsyslog \
        tini \
    && curl -fsSL https://packages.wazuh.com/key/GPG-KEY-WAZUH \
        | gpg --dearmor \
        -o /usr/share/keyrings/wazuh.gpg \
    && chmod 644 /usr/share/keyrings/wazuh.gpg \
    && echo \
        "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
        > /etc/apt/sources.list.d/wazuh.list \
    && apt-get update \
    && WAZUH_MANAGER="${WAZUH_MANAGER}" \
       WAZUH_AGENT_NAME="${WAZUH_AGENT_NAME}" \
       apt-get install -y --no-install-recommends \
       "wazuh-agent=${WAZUH_VERSION}" \
    && apt-mark hold wazuh-agent \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i \
    '/<enrollment>/,/<\/enrollment>/s#<enabled>yes</enabled>#<enabled>no</enabled>#' \
    /var/ossec/etc/ossec.conf

RUN mkdir -p \
      /lab-data/fim-test \
      /var/ossec/etc/persistent \
      /var/ossec/var/run \
    && touch /var/log/hcr-test.log \
    && chown -R wazuh:wazuh \
      /var/ossec/etc/persistent \
      /var/ossec/var/run \
    && chmod 750 /var/ossec/etc/persistent \
    && chmod 640 /var/log/hcr-test.log

COPY entrypoint.sh /usr/local/bin/hcr-entrypoint
COPY healthcheck.sh /usr/local/bin/hcr-healthcheck

RUN chmod 755 \
      /usr/local/bin/hcr-entrypoint \
      /usr/local/bin/hcr-healthcheck

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/hcr-entrypoint"]