PREFIX = ~/.local

mv-incl: mv-incl.zig
	rm -f "$@"
	zig 0.16.0 build-exe "$<"
	sudo chown root:root "$@"
	sudo chmod +s "$@"

install: mv-incl mv-incl-setup
	cp mv-incl-setup $(PREFIX)/bin
	mv mv-incl $(PREFIX)/bin

.PHONY: install
