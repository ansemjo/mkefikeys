
DESTDIR :=

BIN := /usr/bin
DOC := /usr/share/doc

INSTALL := \
	$(DESTDIR)$(BIN)/mkefikeys \
	$(DESTDIR)$(DOC)/mkefikeys/README.md

.PHONY: install
install : $(INSTALL)

$(DESTDIR)$(BIN)/% : %
	install -D -m 755 -t $(@D) $<

$(DESTDIR)$(DOC)/mkefikeys/% : %
	install -D -m 644 -t $(@D) $<
