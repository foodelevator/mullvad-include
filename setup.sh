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

    sudo ip link add dev "$dev" type wireguard

    sudo wg set "$dev" \
        private-key ./privatekey \
        peer "$peer_publickey" \
        endpoint "$peer_endpoint" \
        allowed-ips "$peer_allowed_ips"

    sudo ip netns add "$ns"
    sudo ip link set "$dev" netns "$ns"

    for addr in $addresses; do
        sudo ip -n "$ns" addr add dev "$dev" "$addr"
    done

    sudo ip -n "$ns" link set up dev "$dev"

    sudo ip -n "$ns" route add default dev "$dev" metric 50
}

down() {
    sudo ip netns delete "$ns" || true
    sudo ip link del dev "$dev" || true
}

case "$1" in
    up) up;;
    down) down;;
esac
