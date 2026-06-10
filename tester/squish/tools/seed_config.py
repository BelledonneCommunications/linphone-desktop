#!/usr/bin/env python3
import os
import sys

TEMPLATE = """[sip]
sip_tcp_port=-1
sip_udp_port=-1
sip_tls_port=-1
default_proxy=0

[auth_info_0]
username={user}
passwd={password}
realm={domain}
domain={domain}
algorithm=SHA-256

[proxy_0]
reg_proxy=<sip:{domain};transport=tcp>
reg_identity=sip:{user}@{domain}
reg_expires=3600
reg_sendregister=1
"""


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: seed_config.py <instance_id> <slot>")
    instance_id, slot = sys.argv[1], sys.argv[2]
    prefix = "SQUISH_SIP_" + slot + "_"
    user = os.environ.get(prefix + "USER")
    password = os.environ.get(prefix + "PASS")
    domain = os.environ.get(prefix + "DOMAIN")
    if not user or not password or not domain:
        sys.exit(f"missing {prefix}USER/PASS/DOMAIN in environment")

    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    target_dir = os.path.join(config_home, "linphone-" + instance_id)
    os.makedirs(target_dir, exist_ok=True)
    with open(os.path.join(target_dir, "linphonerc"), "w") as handle:
        handle.write(TEMPLATE.format(user=user, password=password, domain=domain))


if __name__ == "__main__":
    main()
