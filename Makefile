ifeq ($(DESTDIR),)
	destdir=$(HOME)
else
	destdir=$(DESTDIR)
endif

ifeq ($(OPENSMTPD),)
	opensmtpd=$(HOME)/usr/src/OpenSMTPD
else
	opensmtpd=$(OPENSMTPD)
endif

ifeq ($(PACKAGES),)
	packages=$(HOME)/usr/debian-packages
else
	packages=$(PACKAGES)
endif

prefix=$(destdir)/usr/local
exec_prefix=$(prefix)
bindir=$(exec_prefix)/bin
sysconfdir=$(prefix)/etc
sysconfsubdir=$(sysconfdir)/OpenSMTPD-deb

CHMOD=chmod
INSTALL=install
RM=rm
RMDIR=rmdir

all:

install: install-bin install-sysconf

install-bin: create-opensmtpd-deb.sh
	$(INSTALL) -d $(bindir)
	$(INSTALL) $< $(bindir)
	sed -i -e 's!%%packages%%!$(packages)!' $(bindir)/$<
	sed -i -e 's!%%OpenSMTPD%%!$(opensmtpd)!' $(bindir)/$<
	sed -i -e 's!%%sysconfdir%%!$(sysconfdir)!' $(bindir)/$<
	$(CHMOD) 755 $(bindir)/$<

install-sysconf: DEBIAN/postinst DEBIAN/postrm DEBIAN/preinst DEBIAN/prerm \
		DEBIAN/config DEBIAN/10_smtpd.conf.diff
	$(INSTALL) -d $(sysconfsubdir)/etc/init.d
	$(INSTALL) etc/init.d/opensmtpd $(sysconfsubdir)/etc/init.d
	$(INSTALL) -d $(sysconfsubdir)/usr/share/doc/opensmtpd
	$(INSTALL) -m 644 usr/share/doc/opensmtpd/* \
		$(sysconfsubdir)/usr/share/doc/opensmtpd
	$(INSTALL) -d $(sysconfsubdir)/usr/share/lintian/overrides
	$(INSTALL) -m 644 usr/share/lintian/overrides/opensmtpd \
		$(sysconfsubdir)/usr/share/lintian/overrides
	$(INSTALL) $^ $(sysconfsubdir)
	$(CHMOD) 644 $(sysconfsubdir)/10_smtpd.conf.diff

uninstall: uninstall-bin uninstall-sysconf

uninstall-bin: create-opensmtpd-deb.sh
	$(RM) -f $(bindir)/$<
	-$(RMDIR) -p --ignore-fail-on-non-empty $(bindir)

uninstall-sysconf:
	$(RM) -fr $(sysconfsubdir)
	-$(RMDIR) -p --ignore-fail-on-non-empty $(sysconfdir)

.PHONY: all install uninstall
