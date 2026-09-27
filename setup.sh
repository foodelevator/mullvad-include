#!/bin/sh

set -xeuo pipefail

dev=wg-mv-incl
conf="mullvad_wireguard_linux_se_sto/se-sto-wg-001.conf"

addresses="$(awk -F" = " '/^Address/{gsub(",","\n",$2);print($2)}' < "$conf")"
peer_publickey="$(awk -F" = " '/^PublicKey/{print($2)}' < "$conf")"
peer_endpoint="$(awk -F" = " '/^Endpoint/{print($2)}' < "$conf")"
peer_endpoint_ip=${peer_endpoint%%:*}
peer_allowed_ips="$(awk -F" = " '/^AllowedIPs/{print($2)}' < "$conf")"

up() {
    sudo ip link add dev "$dev" type wireguard
    for addr in $addresses; do
        sudo ip addr add dev "$dev" "$addr"
    done
    sudo wg set "$dev" \
        private-key ./privatekey \
        peer "$peer_publickey" \
        endpoint "$peer_endpoint" \
        allowed-ips "$peer_allowed_ips"
    sudo ip link set up dev "$dev"

    route_json="$(ip -j route get "$peer_endpoint_ip" | jq -re '.[0]')"
    r_dst="$(jq -re '.dst' <<< "$route_json")"
    r_gw="$(jq -re '.gateway' <<< "$route_json")"
    r_dev="$(jq -re '.dev' <<< "$route_json")"

    sudo ip route replace "$r_dst/32" via "$r_gw" dev "$r_dev"
    sudo ip route add default dev "$dev" metric 50
}

down() {
    route_json="$(ip -j route get "$peer_endpoint_ip" | jq -re '.[0]')"
    r_dst="$(jq -re '.dst' <<< "$route_json")"
    r_gw="$(jq -re '.gateway' <<< "$route_json")"
    r_dev="$(jq -re '.dev' <<< "$route_json")"
    sudo ip route del "$r_dst/32" via "$r_gw" dev "$r_dev"

    sudo ip route del default dev "$dev" metric 50
    sudo ip link del dev "$dev"
}

case "$1" in
    up) up;;
    down) down;;
esac
