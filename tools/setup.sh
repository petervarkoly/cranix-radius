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

#Enable ntlm auth
NtlmEnabled=$( grep 'ntlm auth = yes' /etc/samba/smb.conf )
if [ -z "${NtlmEnabled}" ]; then
	sed -i '/\[global\]/a ntlm auth = yes' /etc/samba/smb.conf 
	systemctl restart samba
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
#Setup customized certificates
for i in ca.cnf  client.cnf  server.cnf
do
	sed -i "s/#NAME#/${CRANIX_NAME}/"     /etc/raddb/certs/$i
	sed -i "s/#DOMAIN#/${CRANIX_DOMAIN}/" /etc/raddb/certs/$i
done

cd /etc/raddb/certs/
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
./bootstrap

systemctl enable radiusd
systemctl start  radiusd

/usr/bin/fillup /etc/sysconfig/cranix /usr/share/cranix/templates/radius/RADIUS-SETTINGS /etc/sysconfig/cranix 
