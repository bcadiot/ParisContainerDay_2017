#!/bin/bash

set -e
#set the DEBUG env variable to turn on debugging
[[ -n "$DEBUG" ]] && set -x

# Required vars
CONSUL_CONNECT=${CONSUL_CONNECT:-consul.service.consul:8500}
CONSUL_MINWAIT=${CONSUL_MINWAIT:-2s}
CONSUL_MAXWAIT=${CONSUL_MAXWAIT:-10s}
CONSUL_LOGLEVEL=${CONSUL_LOGLEVEL:-info}

# Fixed vars
CONSUL_CONFIG_SOURCE=/app/consul-template/template/index.ctmpl
HTTP_INDEX_DEST=/var/lib/nginx/html/index.html
CONSUL_TEMPLATE=/usr/local/bin/consul-template

function usage {
cat <<USAGE
  launch.sh             Start a consul-backed http instance

Consul-template variables:
  CONSUL_CONNECT        The consul connection
                        (default localhost:8500)

  CONSUL_LOGLEVEL       Valid values are "debug", "info", "warn", and "err".
                        (default is "info")

  CONSUL_TOKEN		Consul ACL token to use
			(default is not set)

USAGE
}

function launch_nginx {
    if [[ -n "${CONSUL_TOKEN}" ]]; then
        ctargs="${ctargs} -token ${CONSUL_TOKEN}"
    fi

    vars=( "$@" )

    mkdir /run/nginx

    exec ${CONSUL_TEMPLATE} -template "${CONSUL_CONFIG_SOURCE}:${HTTP_INDEX_DEST}" \
                       -log-level ${CONSUL_LOGLEVEL} \
                       -wait ${CONSUL_MINWAIT}:${CONSUL_MAXWAIT} \
                       -exec "nginx -g \"daemon off;\"" \
                       -consul ${CONSUL_CONNECT} ${ctargs} "${vars[@]}"

}

launch_nginx "$@"
