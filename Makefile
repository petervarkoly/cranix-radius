# Make file for the SL System Managemant Daemon
DESTDIR         = /
PACKAGE		= oss-radius
REQPACKAGES     = $(shell cat REQPACKAGES)
#VERSION         = $(shell test -e ../VERSION && cp ../VERSION VERSION ; cat VERSION)
VERSION		= $(shell cat VERSION)
RELEASE         = $(shell cat RELEASE)
NRELEASE        = $(shell echo $(RELEASE) + 1 | bc )
HERE		= $(shell pwd)
REPO		= /home/OSC/home:varkoly:OSS-4-0:stable-samba-4.8.9/oss-radius

dist:
	if [ -e $(PACKAGE) ]; then rm -rf $(PACKAGE); fi
	mkdir $(PACKAGE)
	cp Makefile $(PACKAGE)/
	rsync -aC raddb tools $(PACKAGE)/
	tar cjf $(PACKAGE).tar.bz2 $(PACKAGE)
	sed    "s/@VERSION@/$(VERSION)/" $(PACKAGE).spec.in >  $(PACKAGE).spec
	sed -i "s/@RELEASE@/$(RELEASE)/" $(PACKAGE).spec
	if [ -d $(REPO)/$(PACKAGE) ] ; then \
	    cd $(REPO)/$(PACKAGE); osc up; cd $(HERE);\
	    mv $(PACKAGE).tar.bz2 $(PACKAGE).spec $(REPO)/$(PACKAGE); \
	    cd $(REPO)/$(PACKAGE); \
	    osc vc; \
	    osc ci -m "New Build Version"; \
	fi
	echo $(NRELEASE) > RELEASE
	git commit -a -m "New release"
	git push

install:
	  mkdir   -p $(DESTDIR)/usr/share/oss/templates/radius
	  rsync -aC raddb/ $(DESTDIR)/usr/share/oss/templates/radius/
	  mkdir   -p $(DESTDIR)/usr/share/oss/tools/radius
	  rsync -aC tools/ $(DESTDIR)/usr/share/oss/tools/radius/

