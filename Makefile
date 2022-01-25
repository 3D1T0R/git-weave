# Project makefile for git-weave

VERS=$(shell sed <git-weave -n -e '/^version *= *"\(.*\)"/s//\1/p')

SOURCES = README COPYING NEWS git-weave git-weave.txt git-weave.1 Makefile \
	control git-weave-logo.png

all: git-weave.1

.SUFFIXES: .html .txt .1

# Requires asciidoc and xsltproc/docbook stylesheets.
.txt.1:
	a2x --doctype manpage --format manpage -D . $<
.txt.html:
	a2x --doctype manpage --format xhtml -D . $<

clean:
	rm -f *~ *.1 *.html *.rpm *.lsm MANIFEST

prefix?=/usr/local
mandir?=share/man
target=$(DESTDIR)$(prefix)

install: git-weave.1
	install -d "$(target)/bin"
	install -d "$(target)/$(mandir)/man1"
	install -m 755 git-weave "$(target)/bin"
	install -m 644 git-weave.1 "$(target)/$(mandir)/man1"

uninstall:
	rm "$(target)/$(mandir)/man1/git-weave.1"
	rm "$(target)/bin/git-weave"
	-rmdir -p "$(target)/$(mandir)/man1"
	-rmdir -p "$(target)/bin"

pylint:
	@pylint --score=n git-weave

check:
	cd tests; $(MAKE) --quiet

version:
	@echo $(VERS)

git-weave-$(VERS).tar.gz: $(SOURCES)
	@ls $(SOURCES) | sed s:^:git-weave-$(VERS)/: >MANIFEST
	@(cd ..; ln -s git-weave git-weave-$(VERS))
	(cd ..; tar -czf git-weave/git-weave-$(VERS).tar.gz `cat git-weave/MANIFEST`)
	@ls -l git-weave-$(VERS).tar.gz
	@(cd ..; rm git-weave-$(VERS))

dist: git-weave-$(VERS).tar.gz

release: git-weave-$(VERS).tar.gz git-weave.html
	shipper version=$(VERS) | sh -e -x

refresh: git-weave.html
	shipper -N -w version=$(VERS) | sh -e -x
