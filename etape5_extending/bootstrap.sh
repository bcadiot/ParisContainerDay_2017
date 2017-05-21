#!/bin/bash

# Check arch
if [ "$(uname -m)" != "x86_64" ]; then
	cat <<EOF
ERROR: Unsupported architecture: $(uname -m)
Only x86_64 architectures are supported at this time
EOF
	exit 1
fi

# Check arguments

if [[ -z ${1} ]]; then
	cat <<EOF
ERROR: No parameters. Check args.
EOF
exit 1
fi

# Check dist

lsb_dist="$(. /etc/os-release && echo "$ID")"
case "${lsb_dist}" in
	fedora|centos|rhel)
		echo "OK : ${lsb_dist} detected"
		yum clean all
		yum install -y redhat-lsb-core
		;;
	*)
		echo "ERROR: Cannot detect Linux distribution or it's unsupported"
		exit 1
		;;
esac

# Extended Params
OUTPUT_IP="$(ip -o route get 8.8.8.8 |cut -d" " -f8)"
NOMAD_VERSION="0.5.6"
CONSUL_VERSION="0.8.3"
DOMAIN=${DOMAIN:-nomad.test}
NODE_TYPE=${1:-client}
REGION=${2:-us}
DATACENTER=${3:-aws-west2}
EXTERNAL_IP=${4}

install_docker()
{
	lsb_dist="$(lsb_release -si | tr '[:upper:]' '[:lower:]')"
	dist_version="$(lsb_release -sr |cut -d. -f1)"

	cat > /etc/yum.repos.d/docker.repo <<EOF
[docker-repo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/${lsb_dist}/${dist_version}
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

	echo "OK : DockerRepo created"

	yum install -y -q docker-engine docker-engine-selinux
	groupadd docker

	echo "OK : Docker installed"
}

start_services()
{
	if [ -d /run/systemd/system ] ; then
		echo "Enable and start services"
		systemctl daemon-reload || true
		systemctl enable docker || true
		systemctl start docker || true
	fi

	echo "OK : system services enabled and started"
}

stop_services()
{
	if [ -d /run/systemd/system ] ; then
		echo "Enable and start services"
		systemctl daemon-reload || true
		systemctl disable docker || true
		systemctl stop docker || true
	fi

	echo "OK : system services disabled and stopped"
}

start_hashicorp()
{
	if [ -d /run/systemd/system ] ; then
		echo "Enable and start services"
		systemctl daemon-reload || true
		systemctl enable consul || true
		systemctl start consul || true
		systemctl enable nomad || true
		systemctl start nomad || true
	fi

	echo "OK : services enabled and started"
}

stop_hashicorp()
{
	if [ -d /run/systemd/system ] ; then
		echo "Enable and start services"
		systemctl daemon-reload || true
		systemctl disable consul || true
		systemctl stop consul || true
		systemctl disable nomad || true
		systemctl stop nomad || true
	fi

	echo "OK : services disabled and stoped"
}

install_packages()
{
	yum install -y -q unzip wget firewalld
}

install_consul()
{
	wget -qP /tmp https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && unzip /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip -d /usr/bin/ && rm -f /tmp/consul_${CONSUL_VERSION}_linux_amd64.zip

	adduser consul
	mkdir -p /etc/consul /var/consul
	chown consul. /var/consul

	cat > /etc/systemd/system/consul.service <<EOF
[Unit]
Description=Consul Agent
Wants=basic.target
After=basic.target network.target docker.service

[Service]
User=consul
Group=consul
EnvironmentFile=-/etc/sysconfig/consul
ExecStart=/usr/bin/consul agent -config-dir /etc/consul $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

	echo "OK : Consul installed"
}

configure_consul()
{
  if [ ${NODE_TYPE} == "server" ]; then
    cat > /etc/consul/config.json <<EOF
{
    "bootstrap_expect": 3,
    "server": true,
    "datacenter": "${DATACENTER}",
    "data_dir": "/var/consul",
    "log_level": "INFO",
    "enable_syslog": true,
		"bind_addr": "${OUTPUT_IP}",
    "advertise_addr": "${EXTERNAL_IP}"
}

EOF
else
  cat > /etc/consul/config.json <<EOF
  {
      "server": false,
      "datacenter": "${DATACENTER}",
      "data_dir": "/var/consul",
      "log_level": "INFO",
			"bind_addr": "${OUTPUT_IP}",
      "advertise_addr": "${EXTERNAL_IP}"
  }
EOF
fi

	echo "OK : Consul configured"
}

install_nomad()
{
	wget -qP /tmp https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip && unzip /tmp/nomad_${NOMAD_VERSION}_linux_amd64.zip -d /usr/bin/ && rm -f /tmp/nomad_${NOMAD_VERSION}_linux_amd64.zip

	adduser nomad
	mkdir -p /etc/nomad /var/nomad
	chown nomad. /var/nomad

	usermod -G docker -a nomad

	cat > /etc/systemd/system/nomad.service <<EOF
[Unit]
Description=Nomad Agent
Wants=basic.target
After=basic.target network.target consul.service docker.service

[Service]
User=nomad
Group=nomad
EnvironmentFile=-/etc/sysconfig/nomad
ExecStart=/usr/bin/nomad agent -config /etc/nomad $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
EOF

	echo "OK : Nomad installed"
}

configure_nomad()
{
  if [ ${NODE_TYPE} == "server" ]; then
	cat > /etc/nomad/config.hcl <<EOF
	region = "${REGION}"
  datacenter = "${DATACENTER}"
	data_dir = "/var/nomad"
	bind_addr = "0.0.0.0"

	advertise {
		rpc = "${EXTERNAL_IP}"
		http = "${EXTERNAL_IP}"
		serf = "${EXTERNAL_IP}"
	}

  server {
      enabled = true
      bootstrap_expect = 3
  }

  consul {
      address = "127.0.0.1:8500"
  }
EOF
else
	cat > /etc/nomad/config.hcl <<EOF
	region = "${REGION}"
  datacenter = "${DATACENTER}"
  data_dir = "/var/nomad"
  bind_addr = "0.0.0.0"

	advertise {
		rpc = "${EXTERNAL_IP}"
		http = "${EXTERNAL_IP}"
		serf = "${EXTERNAL_IP}"
	}

  client {
      enabled = true
  }
EOF
fi

	echo "OK : Nomad configured"
}

clean_install()
{
	stop_services
	rm -f /usr/bin/consul
	rm -f /etc/consul/config.json
	rm -f /usr/bin/nomad
	rm -f /etc/nomad/config.hcl
	rm -f /etc/systemd/system/nomad.service
	rm -f /etc/yum.repos.d/docker.repo

	echo "OK : Clean install"
}

do_install()
{
	install_packages
	install_docker
	start_services

	install_consul
	configure_consul
	install_nomad
	configure_nomad

  start_hashicorp

	cat <<EOF
************************************
Host installed successfully
************************************
EOF
}

do_install
