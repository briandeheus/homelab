import dataclasses
from typing import List
import psutil
import socket

import requests


@dataclasses.dataclass
class NetworkInterface:
    name: str
    ipv4_address: str | None
    ipv6_address: str | None


def get_network_interfaces() -> List[NetworkInterface]:
    network_interfaces = psutil.net_if_addrs()

    # Loop over each network interface
    for interface_name, addresses in network_interfaces.items():
        ipv4_address = None
        ipv6_address = None
        for address in addresses:
            if address.family == socket.AF_INET:  # IPv4 address
                ipv4_address = address.address
            if address.family == socket.AF_INET6:
                ipv6_address = address.address

        yield NetworkInterface(
            name=interface_name,
            ipv4_address=ipv4_address,
            ipv6_address=ipv6_address,
        )


def get_public_ips() -> [str, str]:
    ips = []
    headers = {"Accept": "text/plain"}

    url = "http://ipv4.icanhazip.com"
    response = requests.get(url, timeout=5)
    ips.append(response.text.strip())

    try:
        url = "http://ipv6.icanhazip.com"
        response = requests.get(url, headers=headers, timeout=5)
        ips.append(response.text.strip())
    except requests.exceptions.ConnectionError:
        ips.append("not found")

    return ips
