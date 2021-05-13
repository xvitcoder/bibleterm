PREFIX = /usr/local

bibleterm: bibleterm.sh bibleterm.awk bible-texts
	cat bibleterm.sh > $@
	echo 'exit 0' >> $@
	echo '#EOF' >> $@
	tar cz bibleterm.awk bible-texts >> $@
	chmod +x $@

test: bibleterm.sh
	shellcheck -s sh bibleterm.sh

clean:
	rm -f bibleterm

install: bibleterm
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f bibleterm $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/bibleterm

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/bibleterm

.PHONY: test clean install uninstall
