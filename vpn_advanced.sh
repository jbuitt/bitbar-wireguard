#!/bin/bash

# Get current status of a Wireguard VPN connection with options to 
# connect/disconnect. Working with Wireguard, but can work with any 
# executable VPN. Commands that require admin permissions should be 
# whitelisted with 'visudo', e.g.:
#
#johndoe ALL=(ALL) NOPASSWD: /usr/local/bin/wg
#johndoe ALL=(ALL) NOPASSWD: /usr/local/bin/wg-quick

# <bitbar.title>Wireguard Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Jim Buitt</bitbar.author>
# <bitbar.author.github>jbuitt</bitbar.author.github>
# <bitbar.dependencies>wireguard,bash</bitbar.dependencies>
# <bitbar.image>https://www.wireguard.com/img/wireguard.svg</bitbar.image>
# <bitbar.desc>Displays status of a Wireguard VPN interface with option to connect/disconnect.</bitbar.desc>

VPN_EXECUTABLE=/usr/local/bin/wg-quick
VPN_INTERFACE="wg0"
VPN_CONNECTED="/sbin/ifconfig -a | grep utun1"
# Command to run to disconnect VPN
VPN_DISCONNECT_CMD="sudo $VPN_EXECUTABLE down $VPN_INTERFACE"

case "$1" in
    connect)
        # VPN connection command, should eventually result in $VPN_CONNECTED,
        # may need to be modified for VPN clients other than Wireguard
        /usr/bin/sudo $VPN_EXECUTABLE up $VPN_INTERFACE &> /dev/null &
        # Wait for connection so menu item refreshes instantly
        until eval "$VPN_CONNECTED"; do sleep 1; done
        ;;
    disconnect)
        eval "$VPN_DISCONNECT_CMD"
        # Wait for disconnection so menu item refreshes instantly
        until [ -z "$(eval "$VPN_CONNECTED")" ]; do sleep 1; done
        ;;
esac

if [ -n "$(eval "$VPN_CONNECTED")" ]; then
    echo "Wireguard ✔"
    echo '---'
    echo "Disconnect VPN | bash='$0' param1=disconnect terminal=false refresh=true"
    echo '---'
    sudo /usr/local/bin/wg
    exit
else
    echo "Wireguard ✘"
    echo '---'
    echo "Connect VPN | bash='$0' param1=connect terminal=false refresh=true"
    exit
fi
