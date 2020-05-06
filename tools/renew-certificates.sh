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

test -e /etc/sysconfig/cranix || exit 0
. /etc/sysconfig/cranix
#Setup customized certificates
for i in ca.cnf  client.cnf  server.cnf 
do
        cp /usr/share/cranix/templates/radius/certs/$i /etc/raddb/certs/$i
        sed -i "s/#NAME#/$CRANIX_NAME/"     /etc/raddb/certs/$i
        sed -i "s/#DOMAIN#/$CRANIX_DOMAIN/" /etc/raddb/certs/$i
done
cp /usr/share/cranix/templates/radius/certs/Makefile /etc/raddb/certs/

cd /etc/raddb/certs/
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
./bootstrap

systemctl enable   radiusd
systemctl restart  radiusd
cd $HERE

