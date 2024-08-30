import os
import socket

import dotenv

from lib import messaging, network

dotenv.load_dotenv()

if __name__ == "__main__":
    messaging.setup(platform=os.environ.get("MESSAGING_PLATFORM"))

    interface_messages = []
    for interface in network.get_network_interfaces():
        interface_messages.append(
            f"{interface.name}: {interface.ipv4_address}, {interface.ipv6_address}"
        )
    interface_messages = "\n".join(interface_messages)

    public_ips = network.get_public_ips()

    startup_message = f"""
Booting up agent.
**Hostname:** 
{socket.gethostname()}
**Network:**
{interface_messages}
**External IP**:
ipv4: {public_ips[0]}
ipv6: {public_ips[1]}
    """.strip()
    messaging.send(startup_message)
