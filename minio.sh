#! /usr/bin/bash
useradd -s /sbin/nologin -d /opt/minio minio
mkdir -p /opt/minio/bin	
wget https://dl.minio.io/server/minio/release/linux-amd64/minio -O /opt/minio/bin/minio
chmod +x /opt/minio/bin/minio
nano /opt/minio/minio.conf