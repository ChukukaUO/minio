#! /usr/bin/bash        ## check with `which bash`

# Create minio user with no shell 
useradd -s /sbin/nologin -d /opt/minio minio

# Directory for server binary and binary file download
mkdir -p /opt/minio/bin	
wget -O /opt/minio/bin/minio --no-check-certificate https://dl.minio.io/server/minio/release/linux-amd64/minio 
chmod +x /opt/minio/bin/minio ## make file executable

# Minio data directory, and configuration file & directory 
mkdir -p /minio/data
chown -R minio:minio /minio/data/
touch /opt/minio/minio.conf         # please see minio.conf file edit section comment
touch /etc/systemd/system/minio.service

# System service configuration
systemctl daemon-reload
systemctl start minio
systemctl enable minio

# Configure firewall to allow port 9000 via TCP
firewall-cmd --zone=public --add-port=9000/tcp --permanent

# BEGIN: telnet localhost 9000      [checking connectivity]
TIMEOUT_SECONDS=5
HOST="localhost"
PORT=9000
timeout $TIMEOUT_SECONDS bash -c "</dev/tcp/${HOST}/${PORT}"
tmp_xiv=$?

if [ $tmp_xiv ]
then 
    echo "Localhost port 9000 is reachable"
else
    echo "ERROR: Localhost port 9000 is unreachable"
fi
# END: 'telnet' [checking connectivity]

# Check mino service status
systemctl status minio

# Sets up minio conf file
cat > /opt/minio/minio.conf <<EOF
-- entries for minio.conf below
MINIO_VOLUMES="/minio/data/"
MINIO_OPTS="--address "
MINIO_ACCESS_KEY="AK************************X"
MINIO_SECRET_KEY="SK*********************MpH"
EOF

# Review or set up service file
cat /etc/systemd/system/minio.service ## review file if downloaded. See next line
# curl -O https://raw.githubusercontent.com/minio/minio-service/master/linux-systemd/minio.service

# 
# for manual edit. See next comment block
#

######
# cat > /etc/systemd/system/minio.service << EOF
# [Unit]
# Description=Minio
# Documentation=https://docs.minio.io
# Wants=network-online.target
# After=network-online.target
# AssertFileIsExecutable=/opt/minio/bin/minio
# 
# [Service]
# WorkingDirectory=/opt/minio
# User=minio
# Group=minio
# PermissionsStartOnly=true
# EnvironmentFile=-/opt/minio/minio.conf
# ExecStartPre=/bin/bash -c "[ -n \"${MINIO_VOLUMES}\" ] || echo \"Variable MINIO_VOLUMES not set in /opt/minio/minio.conf\""
# ExecStart=/opt/minio/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
# StandardOutput=journal
# StandardError=inherit
# # Specifies the maximum file descriptor number that can be opened by this process
# LimitNOFILE=65536
# # Disable timeout logic and wait until process is stopped
# TimeoutStopSec=0
# # SIGTERM signal is used to stop Minio
# KillSignal=SIGTERM
# SendSIGKILL=no
# SuccessExitStatus=0
# [Install]
# WantedBy=multi-user.target
# EOF
#####

# Set up minio default file
#   TODO: confirm if needed higher up in script where file is created.
cat > /etc/default/minio <<EOF
MINIO_OPTS="http://minio-1:9000/data http://minio-2:9000/data http://minio-3:9000/data http://minio-4:9000/data"
MINIO_ACCESS_KEY="AK**************************BX"
MINIO_SECRET_KEY="SKFz********************FMpH"
EOF

# Updates hosts file.
#   TODO: check for duplicate entries and remove; especially in case of reruns
cat >> /etc/hosts << EOF
10.7.7.182    minio-1
10.7.7.183    minio-2
10.7.7.184    minio-3
10.7.7.185    minio-4
127.0.0.1     localhost
EOF