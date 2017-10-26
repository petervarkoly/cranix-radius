# Copyright (c) 2017 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

usage ()
{

        echo '/usr/share/oss/tools/oss-radius/renew-certificates.sh [ -h -d ]'
        echo
        echo 'Renew the oss-radius certificates'
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

test -e /etc/sysconfig/schoolserver || exit 0
. /etc/sysconfig/schoolserver
#Setup customized certificates
for i in ca.cnf  client.cnf  server.cnf
do
        cp /usr/share/oss/templates/oss-radius/certs/$i /etc/raddb/certs/$i
        sed -i "s/#NAME#/$SCHOOL_NAME/"     /etc/raddb/certs/$i
        sed -i "s/#DOMAIN#/$SCHOOL_DOMAIN/" /etc/raddb/certs/$i
done

cd /etc/raddb/certs/
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
./bootstrap

insserv freeradius
rcfreeradius restart
cd $HERE

