# Copyright (c) 2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

usage ()
{

        echo '/usr/share/cranix/tools/radius/renew-certificates.sh [ -h -d ]'
        echo
        echo 'Renew the cranix-radius certificates'
        echo
        echo 'Optional parameters :'
        echo '          -h,   --help         Display this help.'
        echo '          -d,   --description  Display the descriptiont.'

}

HERE=$( pwd )
while [ "$1" != "" ]; do
    case $1 in
        -d | --description )    usage
                                exit;;
        -h | --help )           usage
                                exit;;
    esac
    shift
done

if [ -e /usr/share/doc/packages/cranix-radius-cert ]; then
	echo "Using cranix-radius-cert no renew is necessary"
	exit 0
fi
test -e /etc/sysconfig/cranix || exit 0

# make backup from actuall certificates
DATE=$( /usr/share/cranix/tools/crx_date.sh )
/usr/bin/mkdir -p /var/adm/cranix/backup/${DATE}/etc/raddb/certs/
/usr/bin/rsync -av /etc/raddb/certs/ /var/adm/cranix/backup/${DATE}/etc/raddb/certs/

. /etc/sysconfig/cranix
#Setup customized certificates
for i in ca.cnf  client.cnf  server.cnf xpextensions
do
        /usr/bin/cp /usr/share/cranix/templates/radius/certs/$i /etc/raddb/certs/$i
        /usr/bin/sed -i "s/#NAME#/$CRANIX_NAME/g"     /etc/raddb/certs/$i
        /usr/bin/sed -i "s/#DOMAIN#/$CRANIX_DOMAIN/g" /etc/raddb/certs/$i
done
/usr/bin/cp /usr/share/cranix/templates/radius/certs/Makefile /etc/raddb/certs/

cd /etc/raddb/certs/
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
./bootstrap

/usr/bin/systemctl enable   radiusd
/usr/bin/systemctl restart  radiusd
/usr/bin/cp /etc/raddb/certs/ca.pem /srv/www/admin/radius-ca.pem
/usr/bin/chmod 444 /srv/www/admin/radius-ca.pem
cd $HERE

