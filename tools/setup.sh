# Copyright (c) 2015 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

usage ()
{
        echo '/usr/share/cranix/tools/radius/setup.sh [ -h -d -r ]'
        echo 'Optional parameters :'
        echo '          -h,   --help         Display this help.'
        echo '          -d,   --description  Display the descriptiont.'
        echo '          -r,   --force-reset  Setup the cranix-radius new. Creates new certificates.'

}

RESET=0

while [ "$1" != "" ]; do
    case $1 in
        -r | --force-reset )    RESET=1
                                ;;
        -d | --description )    usage
                                exit;;
        -h | --help )           usage
                                exit;;
    esac
    shift
done

test -e /etc/sysconfig/cranix || exit 0
. /etc/sysconfig/cranix

if [ -e /etc/raddb/certs/dh -a ${RESET} -eq 0 ]; then
	echo "Radius server was already configured"
	exit 0
fi

# make backup from actuall configuration
DATE=$( /usr/share/cranix/tools/crx_date.sh )
mkdir -p /var/adm/cranix/backup/${DATE}/etc/raddb/
rsync -av /etc/raddb/ /var/adm/cranix/backup/${DATE}/etc/raddb/

#Enable ntlm auth
NtlmEnabled=$( grep 'ntlm auth = yes' /etc/samba/smb.conf )
if [ -z "${NtlmEnabled}" ]; then
	sed -i '/\[global\]/a ntlm auth = yes' /etc/samba/smb.conf 
	systemctl restart samba-ad
fi

cd /usr/share/cranix/templates/radius/
for i in $( find -type f )
do
	if [[ $i == *RADIUS-SETTINGS ]]; then
                continue
	fi
	cp $i /etc/raddb/$i
done
ln -fs  ../mods-available/set_logged_on /etc/raddb/mods-enabled/set_logged_on

sed -i "s#CRANIX_SERVER_NET#${CRANIX_SERVER_NET}#" /etc/raddb/clients.conf
sed -i "s#CRANIX_WORKGROUP#${CRANIX_WORKGROUP}#"   /etc/raddb/mods-available/mschap
cd /etc/raddb/certs/
openssl dhparam -out dh 2048

/usr/bin/systemctl daemon-reload
/usr/bin/systemctl enable radiusd
/usr/bin/systemctl start  radiusd

/usr/bin/fillup /etc/sysconfig/cranix /usr/share/cranix/templates/radius/RADIUS-SETTINGS /etc/sysconfig/cranix 
