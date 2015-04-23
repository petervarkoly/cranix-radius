#!/usr/bin/perl

BEGIN { push @INC, "/usr/share/oss/lib/"; }

use strict;
use oss_base;

my $oss = oss_base->new;

my $res = $oss->{LDAP}->search( base   => $oss->{LDAP_BASE},
                                filter => '(&(objectclass=schoolAccount)(!(role=workstations)))',
                                attrs  => [ 'dn' ]
                                );

foreach my $e ( $res->entries )
{
        if( $e->exists('rasAccess') )
        {
                $oss->{LDAP}->modify( $e->dn, replace => { rasAccess => 'all' });
                print "rasAccess all: ".$e->dn."\n";
        }
        else
        {
                $oss->{LDAP}->modify( $e->dn, add => { rasAccess => 'no' });
                print "rasAccess all:  ".$e->dn."\n";
        }
}
