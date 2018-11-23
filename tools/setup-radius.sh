# Copyright (c) 2015 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

usage ()
{
        echo '/usr/share/oss/tools/oss-radius/setup-radius.sh [ -h -d -r ]'
        echo 'Optional parameters :'
        echo '          -h,   --help         Display this help.'
        echo '          -d,   --description  Display the descriptiont.'
        echo '          -r,   --force-reset  Setup the oss-radius new. Creates new certificates.'

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

test -e /etc/sysconfig/schoolserver || exit 0
. /etc/sysconfig/schoolserver

#Enable ntlm auth
NtlmEnabled=$( grep 'ntlm auth = yes' /etc/samba/smb.conf )
if [ -z "${NtlmEnabled}" ]; then
	sed -i '/\[global\]/a ntlm auth = yes' /etc/samba/smb.conf 
fi

cd /usr/share/oss/templates/oss-radius/
for i in $( find -type f )
do
	cp $i /etc/raddb/$i
done

sed -i "s#SCHOOL_SERVER_NET#${SCHOOL_SERVER_NET}#" /etc/raddb/clients.conf
sed -i "s#SCHOOL_WORKGROUP#${SCHOOL_WORKGROUP}#"   /etc/raddb/mods-available/mschap
#Setup customized certificates
for i in ca.cnf  client.cnf  server.cnf
do
	sed -i "s/#NAME#/${SCHOOL_NAME}/"     /etc/raddb/certs/$i
	sed -i "s/#DOMAIN#/${SCHOOL_DOMAIN}/" /etc/raddb/certs/$i
done

cd /etc/raddb/certs/
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
./bootstrap

systemctl enable radiusd
systemctl start  radiusd

