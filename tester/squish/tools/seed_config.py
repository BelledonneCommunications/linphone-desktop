#!/usr/bin/env python3
import argparse
import os

CONFERENCE_FACTORY_URI = "sip:conference-factory@conf.example.org;transport=tls"
LIME_SERVER_URL = "https://lime.wildcard1.linphone.org:8443/lime-server/lime-server.php"
TEST_CA_FILE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "certificates", "cafile.pem"))


def build_config(user, password, domain, conference):
    transport = "tls" if conference else "tcp"
    udp_port = "0" if conference else "-1"
    tcp_port = "0" if conference else "-1"

    root_ca = TEST_CA_FILE if conference else "../share/linphone/rootca.pem"
    sip_section = (
        "[sip]\n"
        "sip_tcp_port=" + tcp_port + "\n"
        "sip_udp_port=" + udp_port + "\n"
        "sip_tls_port=-1\n"
        "root_ca=" + root_ca + "\n"
        "verify_server_certs=1\n"
        "verify_server_cn=1\n"
        "default_proxy=0\n"
    )

    auth_section = (
        "\n[auth_info_0]\n"
        "username=" + user + "\n"
        "passwd=" + password + "\n"
        "realm=" + domain + "\n"
        "domain=" + domain + "\n"
        "algorithm=SHA-256\n"
    )

    proxy_section = (
        "\n[proxy_0]\n"
        "reg_proxy=<sip:" + domain + ";transport=" + transport + ">\n"
        "reg_identity=sip:" + user + "@" + domain + "\n"
        "reg_expires=3600\n"
        "reg_sendregister=1\n"
    )
    if conference:
        proxy_section += (
            "conference_factory_uri=" + CONFERENCE_FACTORY_URI + "\n"
            "lime_server_url=" + LIME_SERVER_URL + "\n"
            "im_encryption_mandatory=0\n"
            "reg_route=<sip:" + domain + ";transport=tls>\n"
        )

    extra = ""
    if conference:
        extra = (
            "\n[misc]\nprefer_basic_chat_room=0\n"
            "\n[lime]\nlime_server_url=" + LIME_SERVER_URL + "\nlime_algo=c25519\n"
        )

    return sip_section + auth_section + proxy_section + extra


def main():
    parser = argparse.ArgumentParser(description="Seed a linphonerc for a test instance")
    parser.add_argument("instance_id")
    parser.add_argument("slot")
    parser.add_argument("--conference", action="store_true",
                        help="Configure the conference factory so 1-to-1 chats use the conference server")
    args = parser.parse_args()

    prefix = "SQUISH_SIP_" + args.slot + "_"
    user = os.environ.get(prefix + "USER")
    password = os.environ.get(prefix + "PASS")
    domain = os.environ.get(prefix + "DOMAIN")
    if not user or not password or not domain:
        raise SystemExit(f"missing {prefix}USER/PASS/DOMAIN in environment")

    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    target_dir = os.path.join(config_home, "linphone-" + args.instance_id)
    os.makedirs(target_dir, exist_ok=True)
    with open(os.path.join(target_dir, "linphonerc"), "w") as handle:
        handle.write(build_config(user, password, domain, args.conference))


if __name__ == "__main__":
    main()
