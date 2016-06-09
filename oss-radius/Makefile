# Make file for the SL System Managemant Daemon
DESTDIR         = /
PACKAGE		= oss-radius
LMDDIR          = $(DESTDIR)/usr/share/lmd
REQPACKAGES     = $(shell cat REQPACKAGES)
VERSION         = $(shell test -e ../VERSION && cp ../VERSION VERSION ; cat VERSION)
RELEASE         = $(shell cat RELEASE)
NRELEASE        = $(shell echo $(RELEASE) + 1 | bc )
HERE		= $(shell pwd)
REPO            = /repo/www/addons/$(PACKAGE)

dist:
	if [ -e $(PACKAGE) ]; then rm -rf $(PACKAGE); fi
	mkdir $(PACKAGE)
	cp Makefile $(PACKAGE)/
	rsync -aC raddb alibs tools $(PACKAGE)/
	tar cjf $(PACKAGE).tar.bz2 $(PACKAGE)
	sed    "s/@VERSION@/$(VERSION)/" $(PACKAGE).spec.in >  $(PACKAGE).spec
	sed -i "s/@RELEASE@/$(RELEASE)/" $(PACKAGE).spec
	mv $(PACKAGE).tar.bz2 /usr/src/packages/SOURCES/
	rpmbuild -bb $(PACKAGE).spec
	rpm --addsign /usr/src/packages/RPMS/noarch/$(PACKAGE)-$(VERSION)-$(RELEASE).noarch.rpm 
	mv /usr/src/packages/RPMS/noarch/$(PACKAGE)-$(VERSION)-$(RELEASE).noarch.rpm $(REPO)/noarch
	cp /data1/OSC/home:openschoolserver/oss-key.gpg $(REPO)/repodata/repomd.xml.key
	createrepo $(REPO)
	gpg -a --detach-sign $(REPO)/repodata/repomd.xml
	echo $(NRELEASE) > RELEASE
	git commit -a -m "New release"
	git push

install:
	  mkdir   -p $(DESTDIR)/usr/share/oss/templates/oss-radius
	  rsync -aC raddb/ $(DESTDIR)/usr/share/oss/templates/oss-radius/
	  mkdir   -p $(DESTDIR)/usr/share/oss/tools/oss-radius
	  rsync -aC tools/ $(DESTDIR)/usr/share/oss/tools/oss-radius/
	  mkdir   -p $(DESTDIR)/usr/share/lmd/alibs
	  rsync -aC alibs/ $(DESTDIR)/usr/share/lmd/alibs/

