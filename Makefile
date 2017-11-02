############################ -*- Mode: Makefile -*- ###########################
## Makefile ---
## Author           : Manoj Srivastava ( srivasta@glaurung.green-gryphon.com )
## Created On       : Tue Nov 18 15:53:52 2003
## Created On Node  : glaurung.green-gryphon.com
## Last Modified By : Manoj Srivastava
## Last Modified On : Sun Apr 12 18:19:56 2009
## Last Machine Used: anzu.internal.golden-gryphon.com
## Update Count     : 36
## Status           : Unknown, Use with caution!
## HISTORY          :
## Description      :
##
###############################################################################
prefix=$(DESTDIR)
package = kernel-package

CONFLOC    := /etc/kernel-pkg.conf
LIBLOC     := /usr/share/kernel-package
MODULE_LOC := /usr/src/modules

DOCFILES = README.modules Rationale Kernel.htm
EXAMPLES = sample.kernel-img.conf etc

# where kernel-package files go to
DEBDIR     = $(LIBLOC)
DEBDIR_NAME= $(shell basename $(DEBDIR))

DOCDIR     = $(prefix)/usr/share/doc/$(package)
MANTOP     = $(prefix)/usr/share/man/
MAN5DIR    = $(prefix)/usr/share/man/man5
MAN1DIR    = $(prefix)/usr/share/man/man1
MAN5DIR    = $(prefix)/usr/share/man/man5
MAN8DIR    = $(prefix)/usr/share/man/man8

version := $(shell dpkg-parsechangelog --show-field Version)


BASH_DIR:= $(prefix)/etc/bash_completion.d

# install commands
install_file   = install -p    -o root -g root -m 644
install_program= install -p    -o root -g root -m 755
make_directory = install -p -d -o root -g root -m 755

all: check

build: check

genpo4a:  po4a/po4a.conf
	if [ -e /usr/bin/po4a ] ; then    \
	  po4a --previous po4a/po4a.conf; \
	fi

check:
	perl  -wc make-kpkg
	-perl -wc kernel/pkg/image/preinst
	-perl -wc kernel/pkg/image/postinst
	-perl  -wc kernel/pkg/image/postrm
	-perl  -wc kernel/pkg/image/prerm
	-perl  -wc kernel/pkg/image/config
	perl  -wc kernel/pkg/headers/postinst
	perl  -wc kernel/pkg/headers/postrm
	perl  -wc kernel/pkg/headers/preinst
	perl  -wc kernel/pkg/headers/prerm
	perl  -wc kernel/pkg/doc/postinst
	perl  -wc kernel/pkg/doc/postrm
	perl  -wc kernel/pkg/doc/preinst
	perl  -wc kernel/pkg/doc/prerm
	perl  -wc kernel/pkg/source/postinst
	perl  -wc kernel/pkg/source/postrm
	perl  -wc kernel/pkg/source/preinst
	perl  -wc kernel/pkg/source/prerm
	bash  -n  kernel/pkg/headers/create_link
	bash  -n  kernel/pkg/virtual/um/postinst
	bash  -n  kernel/pkg/virtual/um/prerm
	bash  -n  kernel/pkg/virtual/xen/postinst
	bash  -n  kernel/pkg/virtual/xen/prerm
	bash -n  kernel/examples/etc/kernel/header_postinst.d/link
	bash -n  kernel/examples/etc/kernel/postinst.d/initramfs
	bash -n  kernel/examples/etc/kernel/postinst.d/symlink_hook
	bash -n  kernel/examples/etc/kernel/postinst.d/grub_conf
	bash -n  kernel/examples/etc/kernel/postinst.d/force-build-link
	bash -n  kernel/examples/etc/kernel/postinst.d/yaird
	bash -n  kernel/examples/etc/kernel/header_prerm.d/link
	bash -n  kernel/examples/etc/kernel/postrm.d/initramfs
	bash -n  kernel/examples/etc/kernel/postrm.d/grub_rm
	bash -n  kernel/examples/etc/kernel/postrm.d/force-build-link
	bash -n  kernel/examples/etc/kernel/postrm.d/yaird
	bash -n  kernel/examples/etc/kernel/header_postrm.d/link

install: genpo4a
	$(make_directory)  $(MAN1DIR)
	$(make_directory)  $(MAN5DIR)
	$(make_directory)  $(MAN8DIR)
	$(make_directory)  $(DOCDIR)/examples
	$(make_directory)  $(BASH_DIR)
	$(make_directory)  $(prefix)/usr/bin
	$(make_directory)  $(prefix)/usr/sbin
	$(make_directory)  $(prefix)/usr/share/$(package)/docs
	$(install_file)    debian/changelog                  $(DOCDIR)/changelog
	$(install_file)    README                            $(DOCDIR)/README
	$(install_file)    Problems                          $(DOCDIR)/Problems
	$(install_file)    debian/NEWS.Debian                $(DOCDIR)/
	$(install_file)    _make-kpkg                        $(BASH_DIR)/make_kpkg
	gzip -9fqr         $(DOCDIR)
	(cd $(DOCDIR);     for file in $(DOCFILES); do                  \
                            ln -s ../../$(package)/docs/$$file $$file;  \
                           done)
	$(install_file)    debian/copyright  	      $(DOCDIR)/copyright
	$(install_file)    kernel-pkg.conf.5 	      $(MAN5DIR)/kernel-pkg.conf.5
	$(install_file)    kernel-img.conf.5 	      $(MAN5DIR)/kernel-img.conf.5
	$(install_file)    kernel-package.5  	      $(MAN5DIR)/kernel-package.5
	$(install_file)    make-kpkg.8       	      $(MAN1DIR)/make-kpkg.1
	$(install_file)    kernel-packageconfig.8     $(MAN8DIR)/
	for lang in de fr; do                                                                             \
          test ! -f kernel-pkg.conf.$$lang.5          || test -d $(MANTOP)/$$lang/man5    ||           \
                                                         mkdir -p $(MANTOP)/$$lang/man5;               \
          test ! -f kernel-pkg.conf.$$lang.5          ||                                               \
           $(install_file) kernel-pkg.conf.$$lang.5   $(MANTOP)/$$lang/man5/kernel-pkg.conf.5;         \
          test ! -f kernel-img.conf.$$lang.5          || test -d $(MANTOP)/$$lang/man5    ||           \
                                                         mkdir -p $(MANTOP)/$$lang/man5;               \
          test ! -f kernel-img.conf.$$lang.5          ||                                               \
           $(install_file) kernel-img.conf.$$lang.5   $(MANTOP)/$$lang/man5/kernel-img.conf.5;         \
          test ! -f kernel-package.$$lang.5           || test -d $(MANTOP)/$$lang/man5    ||           \
                                                         mkdir -p $(MANTOP)/$$lang/man5;               \
          test ! -f kernel-package.$$lang.5           ||                                               \
           $(install_file) kernel-package.$$lang.5    $(MANTOP)/$$lang/man5/kernel-package.5;          \
          test ! -f make-kpkg.$$lang.8                || test -d $(MANTOP)/$$lang/man1    ||           \
                                                         mkdir -p $(MANTOP)/$$lang/man1;               \
          test ! -f make-kpkg.$$lang.8                ||                                               \
           $(install_file) make-kpkg.$$lang.8         $(MANTOP)/$$lang/man1/make-kpkg.1;               \
          test ! -f kernel-packageconfig.$$lang.8     || test -d $(MANTOP)/$$lang/man8    ||           \
                                                         mkdir -p $(MANTOP)/$$lang/man8;               \
          test ! -f kernel-packageconfig.$$lang.8     ||                                               \
           $(install_file) kernel-packageconfig.$$lang.8 $(MANTOP)/$$lang/man8/kernel-packageconfig.8; \
        done
	gzip -9fqr         $(prefix)/usr/share/man
	$(install_file)    kernel-pkg.conf            $(prefix)/etc/kernel-pkg.conf
	$(install_program) kernel-packageconfig       $(prefix)/usr/sbin/kernel-packageconfig
	$(install_program) make-kpkg                  $(prefix)/usr/bin/make-kpkg
	perl -pli          -e 's/=K=V/$(version)/'    $(prefix)/usr/bin/make-kpkg
	$(install_file)    Rationale                  $(prefix)/usr/share/$(package)/docs/
	(cd kernel;        tar cf - * |                                         \
           (cd             $(prefix)/usr/share/$(package); umask 000;           \
                           tar xpf -))
	test ! -d          $(prefix)/usr/share/$(package)/ruleset/common/\{arch\} || \
               rm -rf      $(prefix)/usr/share/$(package)/ruleset/common/\{arch\}
	find $(prefix)/usr/share/$(package) -type d -name .arch-ids -print0 |   \
           xargs -0r rm -rf
	test ! -d $(prefix)/usr/share/$(package)/examples ||                       \
             for example in $(prefix)/usr/share/$(package)/examples/*; do          \
                 file=`basename $$example`;                                        \
                 ln -s ../../../$(package)/examples/$$file $(DOCDIR)/examples/$$file; \
             done
# Hack, tell the   rules file what version of kernel package it is
	sed -e             's/=K=V/$(version)/' kernel/rules > \
                              $(prefix)/usr/share/$(package)/rules
	chmod  0755          $(prefix)/usr/share/$(package)/rules

clean distclean:
	for lang in de fr; do                        \
          test ! -f kernel-pkg.conf.$$lang.5 ||      \
            rm  kernel-pkg.conf.$$lang.5      ;      \
	  test ! -f kernel-img.conf.$$lang.5 ||      \
            rm  kernel-img.conf.$$lang.5      ;      \
	  test ! -f kernel-package.$$lang.5 ||       \
            rm  kernel-package.$$lang.5       ;      \
	  test ! -f make-kpkg.$$lang.8 ||            \
            rm  make-kpkg.$$lang.8            ;      \
	  test ! -f kernel-packageconfig.$$lang.8 || \
            rm  kernel-packageconfig.$$lang.8 ;      \
        done
