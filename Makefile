# Make file for the SL System Managemant Daemon
DESTDIR         = /
PACKAGE		= cranix-radius
REQPACKAGES     = $(shell cat REQPACKAGES)
HERE		= $(shell pwd)
REPO		= /home/OSC/home:varkoly:CRANIX-4-2:leap15.2/

dist:
	if [ -e $(PACKAGE) ]; then rm -rf $(PACKAGE); fi
	mkdir $(PACKAGE)
	cp Makefile $(PACKAGE)/
	rsync -aC raddb tools $(PACKAGE)/
	tar cjf $(PACKAGE).tar.bz2 $(PACKAGE)
	xterm -e git log --raw &
	if [ -d $(REPO)/$(PACKAGE) ] ; then \
	    cd $(REPO)/$(PACKAGE); osc up; cd $(HERE);\
	    mv $(PACKAGE).tar.bz2 $(REPO)/$(PACKAGE); \
	    cd $(REPO)/$(PACKAGE); \
	    osc vc; \
	    osc ci -m "New Build Version"; \
	fi

install:
	  mkdir   -p $(DESTDIR)/usr/share/cranix/templates/radius
	  rsync -aC raddb/ $(DESTDIR)/usr/share/cranix/templates/radius/
	  mkdir   -p $(DESTDIR)/usr/share/cranix/tools/radius
	  rsync -aC tools/ $(DESTDIR)/usr/share/cranix/tools/radius/

