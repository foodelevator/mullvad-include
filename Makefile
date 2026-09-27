mullvad-include: mullvad-include.zig
	rm -f "$@"
	zig 0.16.0 build-exe "$<"
	sudo chown root:root "$@"
	sudo chmod +s "$@"
