PREFIX = ~/.local
SUDO = sudo
CFLAGS = -std=c99 -Os -Wall -Werror -Wextra -pedantic

mv-incl: mv-incl.c
	rm -f "$@"
	$(CC) $(CFLAGS) -o mv-incl mv-incl.c
	$(SUDO) chown root:root "$@"
	$(SUDO) chmod 4755 "$@"

install: mv-incl mv-incl-setup
	cp mv-incl-setup $(PREFIX)/bin
	mv -f mv-incl $(PREFIX)/bin

.PHONY: install
