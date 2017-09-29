#!/bin/bash

. /etc/sysconfig/schoolserver
REPO_USER=${SCHOOL_REG_CODE:0:9}
REPO_PASSWORD=${SCHOOL_REG_CODE:10:9}
PKGNAME="oss-radius"

echo "[$PKGNAME]
name=$PKGNAME
enabled=1
autorefresh=1
baseurl=https://$REPO_USER:$REPO_PASSWORD@repo.openschoolserver.net/addons/$PKGNAME
path=/
type=rpm-md
keeppackages=0
" > /tmp/$PKGNAME.repo

wget -O repomd.xml.key https://$REPO_USER:$REPO_PASSWORD@repo.openschoolserver.net/addons/$PKGNAME/repodata/repomd.xml.key
gpg --import repomd.xml.key
zypper ar /tmp/$PKGNAME.repo
zypper --gpg-auto-import-keys ref $PKGNAME
rm /tmp/$PKGNAME.repo
zypper -n install $PKGNAME
zypper -n mr -r $PKGNAME

