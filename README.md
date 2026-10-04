# mullvad-include

`mullvad-exclude` allows running certain programs outside of the VPN while programs by default run
within the VPN.

This does the opposite: while programs by default run outside of the VPN, you can easily run
certain programs within it.

> [!NOTE]
> This is an independent project, not affiliated with or endorsed by Mullvad VPN.

## Requirements

- Linux
- The Mullvad VPN daemon authenticated to a Mullvad VPN account
- `ip` (iproute2), `setpriv` (util-linux), `wg` (wireguard-tools),
  `curl`, `jq`, GNU coreutils, and a shell

Building also requires a C99 compiler and make.

## Installation

```sh
make install
```

Installs into `~/.local/bin` by default. Install system wide using e.g.
`make PREFIX=/usr/local install`.

## Setup

```sh
mv-incl-setup
```

Must be run after every boot. It takes credentials (account number and WireGuard private key) from
the Mullvad VPN daemon. The Mullvad daemon must have credentials saved (using e.g. `mullvad account
login`), but not necessarily be running. It picks a random Mullvad relay in Stockholm.

Tear it down using

```sh
mv-incl-setup down
```

## Running a program

Execute any program with `mv-incl` prepended. For instance:

```sh
mv-incl curl https://curlmyip.net
```

The program still has full access to your system. Only its network namespace is isolated. It also
makes `/etc/resolv.conf` appear to point to Mullvad's DNS.

If you want additional configuration in `/etc/` for programs run with `mv-incl`, you can put such
files in `/etc/netns/mv-incl`.

## Security

Running `mv-incl-setup` requires being root. If not run as root, it will re-execute itself with
`sudo`.

`mv-incl` is a SUID binary which uses `ip netns exec` to execute in a separate network namespace
(and perform bind mounts) and `setpriv` to retain the calling user's privileges when executing the
requested program (rather than letting the caller execute arbitrary programs as root). This means
that any user on the system can execute programs in the network namespace used by Mullvad-include.
Running `mv-incl` thus only makes outbound traffic and DNS requests go through Mullvad. This project
does not consider that specifically to be an escalation of privileges.

Preventing programs ran by `mv-incl` from reaching the internet directly, without going through the
VPN, is best-effort and by no means guaranteed. Also note that `mv-incl` is **not** a sandbox by any
means. This means that programs can communicate with other programs. One common instance of this is
that executing a web browser when it already is running usually just tells the running instance to
open a new window. If the existing browser was started without `mv-incl`, it will then connect to
the internet without going through Mullvad.

While an attempt to make DNS requests go through Mullvad's DNS server is made, it is done in
quite a brittle way and probably does not work at all on some setups.

All that said, running `mv-incl chromium https://mullvad.net/en/check` (with no existing chromium
instance running) reports no leaks on my computer.
