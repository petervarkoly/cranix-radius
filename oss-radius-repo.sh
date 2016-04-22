#!/bin/bash

. /etc/sysconfig/schoolserver
REPO_USER=${SCHOOL_REG_CODE:0:9}
REPO_PASSWORD=${SCHOOL_REG_CODE:10:9}

echo "[oss-radius]
name=oss-radius
enabled=1
autorefresh=1
baseurl=https://$REPO_USER:$REPO_PASSWORD@repo.openschoolserver.net/addons/oss-radius
path=/
type=rpm-md
keeppackages=0
" > /tmp/oss-radius.repo

wget -O repomd.xml.key https://$REPO_USER:$REPO_PASSWORD@repo.openschoolserver.net/addons/oss-radius/repodata/repomd.xml.key
gpg --import repomd.xml.key
zypper ar /tmp/oss-radius.repo
zypper --gpg-auto-import-keys ref
zypper -n install oss-radius
rclmd restart

