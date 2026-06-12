#!/usr/bin/env python3
import argparse
import os

ACCOUNT_TEMPLATE = """[sip]
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
    parser = argparse.ArgumentParser(description="Seed a linphonerc with [ui] settings for a test instance")
    parser.add_argument("instance_id")
    parser.add_argument("--slot", default="")
    parser.add_argument("--ui", action="append", default=[], metavar="KEY=VALUE")
    parser.add_argument("--proxy", action="append", default=[], metavar="KEY=VALUE")
    args = parser.parse_args()

    content = ""
    if args.slot:
        prefix = "SQUISH_SIP_" + args.slot + "_"
        user = os.environ.get(prefix + "USER")
        password = os.environ.get(prefix + "PASS")
        domain = os.environ.get(prefix + "DOMAIN")
        if not user or not password or not domain:
            raise SystemExit(f"missing {prefix}USER/PASS/DOMAIN in environment")
        account = ACCOUNT_TEMPLATE.format(user=user, password=password, domain=domain)
        if args.proxy:
            account = account.rstrip("\n") + "\n" + "\n".join(args.proxy) + "\n"
        content += account

    content += "\n[ui]\n" + "\n".join(args.ui) + "\n"

    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    target_dir = os.path.join(config_home, "linphone-" + args.instance_id)
    os.makedirs(target_dir, exist_ok=True)
    with open(os.path.join(target_dir, "linphonerc"), "w") as handle:
        handle.write(content)


if __name__ == "__main__":
    main()
