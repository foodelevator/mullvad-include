PREFIX = ~/.local

mv-incl: mv-incl.c
	rm -f "$@"
	gcc -std=c99 -Os -o mv-incl mv-incl.c -Wall -Werror -Wextra -pedantic
	sudo chown root:root "$@"
	sudo chmod +s "$@"

install: mv-incl mv-incl-setup
	cp mv-incl-setup $(PREFIX)/bin
	mv mv-incl $(PREFIX)/bin

.PHONY: install
