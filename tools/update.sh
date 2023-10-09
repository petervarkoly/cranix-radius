# Copyright (c) 2015 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

usage ()
{
        echo '/usr/share/cranix/tools/radius/setup.sh [ -h -d -r ]'
        echo 'Optional parameters :'
        echo '          -h,   --help         Display this help.'
        echo '          -d,   --description  Display the descriptiont.'

}

RESET=0

while [ "$1" != "" ]; do
    case $1 in
        -d | --description )    usage
                                exit;;
        -h | --help )           usage
                                exit;;
    esac
    shift
done

test -e /etc/sysconfig/cranix || exit 0
. /etc/sysconfig/cranix

DATE=$( /usr/share/cranix/tools/crx_date.sh )
#Enable ntlm auth
NtlmEnabled=$( grep 'ntlm auth = yes' /etc/samba/smb.conf )
if [ -z "${NtlmEnabled}" ]; then
	sed -i '/\[global\]/a ntlm auth = yes' /etc/samba/smb.conf 
	systemctl restart samba
fi

cd /usr/share/cranix/templates/radius/
for i in $( find -type f )
do
	if [[ $i == *clients.conf ]]; then
		continue
	fi
        if [[ $i == *RADIUS-SETTINGS ]]; then
                continue
        fi
	cp /etc/raddb/$i /etc/raddb/$i.$DATE
	cp $i /etc/raddb/$i
done
ln -fs  ../mods-available/set_logged_on /etc/raddb/mods-enabled/set_logged_on

sed -i "s#CRANIX_SERVER_NET#${CRANIX_SERVER_NET}#" /etc/raddb/clients.conf
sed -i "s#CRANIX_WORKGROUP#${CRANIX_WORKGROUP}#"   /etc/raddb/mods-available/mschap

# Check how long the certificate is valide
UNTIL=$( /usr/bin/date -d "$(/usr/bin/openssl x509 -in /etc/raddb/certs/server.pem -text | grep 'Not After :' | sed 's/.*Not After : //')" +%s )
NOW=$( /usr/bin/date +%s )
if [ $((UNTIL-NOW)) -lt 129600 ]; then
	/usr/share/cranix/tools/radius/renew-certificates.sh
fi

# Check if the certficate contains the domain name
CN=$(/usr/bin/openssl x509 -in /etc/raddb/certs/server.pem -text | grep  "CN = ${CRANIX_DOMAIN}")
if [ -z "$CN" ]; then
	/usr/share/cranix/tools/radius/renew-certificates.sh
fi

/usr/bin/systemctl daemon-reload
/usr/bin/systemctl enable  radiusd
/usr/bin/systemctl restart radiusd

/usr/bin/fillup /etc/sysconfig/cranix /usr/share/cranix/templates/radius/RADIUS-SETTINGS /etc/sysconfig/cranix

