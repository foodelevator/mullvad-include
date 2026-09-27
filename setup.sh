#!/bin/sh

set -xeuo pipefail

dev=wg-mv-incl
ns=mv-incl

up() {
    conf="mullvad_wireguard_linux_se_sto/se-sto-wg-001.conf"

    addresses="$(awk -F" = " '/^Address/{gsub(",","\n",$2);print($2)}' < "$conf")"
    peer_publickey="$(awk -F" = " '/^PublicKey/{print($2)}' < "$conf")"
    peer_endpoint="$(awk -F" = " '/^Endpoint/{print($2)}' < "$conf")"
    peer_endpoint_ip=${peer_endpoint%%:*}
    peer_allowed_ips="$(awk -F" = " '/^AllowedIPs/{print($2)}' < "$conf")"
    dns="$(awk -F" = " '/^DNS/{print($2)}' < "$conf")"

    mkdir -p "/etc/netns/$ns"
    echo "nameserver $dns" > "/etc/netns/$ns/resolv.conf"

    ip link add dev "$dev" type wireguard

    wg set "$dev" \
        private-key ./privatekey \
        peer "$peer_publickey" \
        endpoint "$peer_endpoint" \
        allowed-ips "$peer_allowed_ips"

    ip netns add "$ns"
    ip link set "$dev" netns "$ns"

    for addr in $addresses; do
        ip -n "$ns" addr add dev "$dev" "$addr"
    done

    ip -n "$ns" link set up dev "$dev"

    ip -n "$ns" route add default dev "$dev" metric 50
}

down() {
    ip netns delete "$ns" || true
    ip link del dev "$dev" || true
    rm -fd "/etc/netns/$ns/resolv.conf" "/etc/netns/$ns"
}

[[ "$UID" != 0 ]] && exec sudo -E "$(readlink -f "$0")" "$@"

case "$1" in
    up) up;;
    down) down;;
esac
