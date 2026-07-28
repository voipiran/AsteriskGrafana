#!/bin/bash

###############################################################################
# VoIPIran Grafana Installer for Issabel 5
# Installs Grafana, creates a read-only MySQL user, provisions datasources
# and dashboards automatically.
###############################################################################

set -e

echo "========================================================="
echo "      VoIPIran Grafana Installer for Issabel 5"
echo "========================================================="

###############################################################################
# Check root privileges
###############################################################################

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Please run this installer as root."
    exit 1
fi

###############################################################################
# Read Issabel MySQL root password
###############################################################################

rootpw=$(sed -ne 's/.*mysqlrootpwd=//gp' /etc/issabel.conf)

if [[ -z "$rootpw" ]]; then
    echo "ERROR: Unable to read MySQL root password from /etc/issabel.conf"
    exit 1
fi

echo "MySQL root password loaded."

###############################################################################
# Install Grafana repository
###############################################################################

echo "Installing Grafana repository..."

cat >/etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=Grafana OSS
baseurl=https://packages.grafana.com/oss/rpm
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF

###############################################################################
# Install Grafana
###############################################################################

echo "Installing Grafana..."

yum install -y grafana jq

###############################################################################
# Enable Grafana service
###############################################################################

echo "Starting Grafana..."

systemctl enable grafana-server
systemctl start grafana-server

###############################################################################
# Create read-only MySQL user
###############################################################################

echo "Creating Grafana MySQL user..."

mysql -u root -p"$rootpw" <<EOF

CREATE USER IF NOT EXISTS 'grafana'@'localhost'
IDENTIFIED BY '$rootpw';

GRANT SELECT ON *.* TO 'grafana'@'localhost';

FLUSH PRIVILEGES;

EOF

###############################################################################
# Install datasource provisioning
###############################################################################

echo "Installing datasource provisioning..."

mkdir -p /etc/grafana/provisioning/datasources

sed "s/__MYSQL_ROOT_PASSWORD__/${rootpw}/g" \
grafana/provisioning/datasources/datasources.yaml.template \
> /etc/grafana/provisioning/datasources/datasources.yaml

###############################################################################
# Install dashboard provisioning
###############################################################################

echo "Installing dashboard provisioning..."

mkdir -p /etc/grafana/provisioning/dashboards

cp grafana/provisioning/dashboards/dashboards.yaml \
/etc/grafana/provisioning/dashboards/

###############################################################################
# Install dashboards
###############################################################################

echo "Installing dashboards..."

mkdir -p /var/lib/grafana/dashboards

cp grafana/dashboards/*.json \
/var/lib/grafana/dashboards/

###############################################################################
# Fix permissions
###############################################################################

echo "Setting permissions..."

chown -R grafana:grafana /etc/grafana/provisioning
chown -R grafana:grafana /var/lib/grafana/dashboards

###############################################################################
# Restart Grafana
###############################################################################

echo "Restarting Grafana..."

systemctl restart grafana-server

###############################################################################
# Done
###############################################################################

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "========================================================="
echo "Installation completed successfully."
echo ""
echo "Grafana URL : http://${IP}:3000"
echo "Username    : admin"
echo "Password    : admin"
echo ""
echo "You will be asked to change the password on first login."
echo "========================================================="