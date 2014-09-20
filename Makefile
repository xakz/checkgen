########################################################################
# The MIT License (MIT)
#
# Copyright (c) 2014, Maxime Chatelle, All rights reserved.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
########################################################################

prefix		:= /usr/local
bindir		:= $(prefix)/bin
mandir		:= $(prefix)/share/man
DESTDIR		:=

CFLAGS		:= $(shell pkg-config --cflags check)
LDLIBS		:= $(shell pkg-config --libs check)

PROGNAME	:= checkgen
MANSECTION	:= 1
DOCBOOKXML	:= $(PROGNAME).xml
MANPAGE		:= $(PROGNAME).$(MANSECTION)
HTMLMAN		:= $(PROGNAME).html
XSLTPROCMAN	:= xsltproc --xinclude \
			/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/manpages/docbook.xsl
XSLTPROCHTML	:= xsltproc --xinclude \
			--param generate.css.header 1 \
			--stringparam custom.css.source docbook.css.xml \
			/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/xhtml-1_1/docbook.xsl

NOLINESYNC_EXT	:= .nolinesync.c
EXAMPLES	:= $(wildcard example.*.ts)
EX_CLEANS	:= $(EXAMPLES:.ts=$(NOLINESYNC_EXT))
EX_SRCS		:= $(EXAMPLES:.ts=.c)
EX_OBJS		:= $(EXAMPLES:.ts=.o)
EX_EXES		:= $(EXAMPLES:.ts=)

all: examples

install: $(PROGNAME) $(MANPAGE)
	install -m755 -d $(DESTDIR)$(bindir)
	install -m755 -t $(DESTDIR)$(bindir) $(PROGNAME)
	install -m755 -d $(DESTDIR)$(mandir)/man$(MANSECTION)
	install -m644 -t $(DESTDIR)$(mandir)/man$(MANSECTION) $(MANPAGE)
uninstall:
	rm -f $(DESTDIR)$(bindir)/$(PROGNAME)
	rm -f $(DESTDIR)$(mandir)/man$(MANSECTION)/$(MANPAGE)
examples: $(EX_EXES) $(EX_CLEANS)
%.c: %.ts
	./$(PROGNAME) $< > $@
%$(NOLINESYNC_EXT): %.ts
	./$(PROGNAME) NOLINESYNC=1 $< > $@
clean:
	rm -f $(EX_OBJS) $(EX_SRCS)
distclean: clean
	rm -f $(EX_EXES) $(EX_CLEANS)
maintainer-clean: distclean
	rm -f $(MANPAGE) $(HTMLMAN)

.PHONY: all install uninstall examples clean distclean maintainer-clean

# Targets that rebuilds documentation files, requires Docbook 5
# stylesheets and xsltproc (libxml2)
doc: man html
man: $(MANPAGE)
$(MANPAGE): $(DOCBOOKXML) $(EXAMPLES) $(EX_CLEANS) COPYING
	$(XSLTPROCMAN) $<

html: $(HTMLMAN)
$(HTMLMAN): $(DOCBOOKXML)  $(EXAMPLES) $(EX_CLEANS) COPYING docbook.css.xml
	$(XSLTPROCHTML) $< > $@

.PHONY: doc man html

# Keeps all intermediary source files for user review.
.PRECIOUS: %.c
