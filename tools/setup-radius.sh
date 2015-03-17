# Copyright (c) 2015 Peter Varkoly <peter@varkoly.de> Nürnberg, Germany.  All rights reserved.

usage ()
{
        echo '/usr/share/oss/tools/oss-radius/setup-radius.sh [ -h -d -r ]'
        echo 'Optional parameters :'
        echo '          -h,   --help         Display this help.'
        echo '          -d,   --description  Display the descriptiont.'
        echo '          -r,   --force-reset  Setup the oss-radius new. Creates a new ossradius account and certificates.'

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
. /etc/sysconfig/ldap
. /etc/sysconfig/schoolserver
LDAPBASE=`echo $BIND_DN | sed 's/cn=Administrator,//'`

if [ "$(ldapsearch -LLLx '(&(cKey=SCHOOL_USE_RADIUS)(cValue=yes))' dn)" -a "$(ldapsearch -LLLx '(cn=ossradius)' dn)" -a $RESET = 0 ]
then
	DATE=$( /usr/share/oss/tools/oss_date.sh )
	cp /usr/share/oss/tools/oss-radius/oss_set_logon.pl /usr/share/oss/tools/oss-radius/oss_set_logon.pl-$DATE
	chmod 600 /usr/share/oss/tools/oss-radius/oss_set_logon.pl-$DATE
	PASSWORD=$( oss_ldapsearch cn=ossradius userPassword | grep userPassword | sed 's/userPassword:: //' | base64 -d )
	sed    s#PASSWORD#$PASSWORD#     /usr/share/oss/tools/oss-radius/oss_set_logon.pl.in > /usr/share/oss/tools/oss-radius/oss_set_logon.pl
	sed -i s/LDAPBASE/$LDAPBASE/     /usr/share/oss/tools/oss-radius/oss_set_logon.pl
	chgrp radiusd /usr/share/oss/tools/oss-radius/oss_set_logon.pl
	chmod 750     /usr/share/oss/tools/oss-radius/oss_set_logon.pl
	exit 0
fi

if [ $RESET = 1 ]; then
   oss_ldapdelete "cn=ossradius,ou=daemonadmins,$LDAPBASE"
fi

PASSWORD=$(mktemp -u XXXXXXXX)
cd /usr/share/oss/templates/oss-radius/
for i in $( find -type f )
do
	cp $i /etc/raddb/$i
done

sed -i s#SCHOOL_SERVER_NET#$SCHOOL_SERVER_NET# /etc/raddb/clients.conf
sed -i s#PASSWORD#$PASSWORD#     /etc/raddb/modules/ldap
sed -i s/LDAPBASE/$LDAPBASE/     /etc/raddb/modules/ldap
sed    s#PASSWORD#$PASSWORD#     /usr/share/oss/tools/oss-radius/oss_set_logon.pl.in > /usr/share/oss/tools/oss-radius/oss_set_logon.pl
sed -i s/LDAPBASE/$LDAPBASE/     /usr/share/oss/tools/oss-radius/oss_set_logon.pl
chgrp radiusd /usr/share/oss/tools/oss-radius/oss_set_logon.pl
chmod 750     /usr/share/oss/tools/oss-radius/oss_set_logon.pl
echo "SCHOOL_USE_RADIUS
yes
The OSS use the freeradius server
yesno
yes
Basis" | /usr/sbin/oss_base_wrapper.pl add_school_config

# Add daemon admin
echo "dn: ou=daemonadmins,$LDAPBASE
objectClass: organizationalUnit
ou: daemonadmins" | /usr/sbin/oss_ldapadd

echo "dn: cn=ossradius,ou=daemonadmins,$LDAPBASE
objectClass: top
objectClass: person
userPassword: $PASSWORD
cn: ossradius
sn: Admin User for FreeRadius Daemon" | /usr/sbin/oss_ldapadd

#Add new acls
echo "dn: olcDatabase={1}hdb,cn=config
add: olcAccess
olcAccess: {2}to attrs=configurationValue by dn.exact=\"cn=ossradius,ou=daemonadmins,$LDAPBASE\" write by * read break
olcAccess: {3}to attrs=sambaNTPassword,sambaLMPassword by dn.exact=\"cn=ossradius,ou=daemonadmins,$LDAPBASE\" read  by * auth break
" | ldapmodify -Y external -H ldapi:/// 

#Add index for rasAccess
echo "dn: olcDatabase={1}hdb,cn=config
add: olcDbIndex
olcDbIndex: rasAccess eq" | ldapmodify -Y external -H ldapi:///

rcldap restart

#Setup customized certificates
for i in ca.cnf  client.cnf  server.cnf
do
	sed -i s/#NAME#/$SCHOOL_NAME/     /etc/raddb/certs/$i
	sed -i s/#DOMAIN#/$SCHOOL_DOMAIN/ /etc/raddb/certs/$i
done

cd /etc/raddb/certs/
rm -f *.pem *.der *.csr *.crt *.key *.p12 serial* index.txt*
./bootstrap

/usr/share/oss/tools/oss-radius/close-ras.pl
/usr/sbin/oss_ldap_to_sysconfig.pl
insserv freeradius
rcfreeradius start
