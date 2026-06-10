#!/usr/bin/env python3
import argparse
import json
import os
import secrets
import shlex
import string
import sys
import urllib.error
import urllib.request

DEFAULT_URL = os.environ.get("FLEXIAPI_URL", "http://subscribe.example.org/flexiapi/api/")
DEFAULT_DOMAIN = os.environ.get("SIP_DOMAIN", "sip.example.org")
DEFAULT_FROM = os.environ.get("FLEXIAPI_FROM", "sip:admin_test@sip.example.org")
DEFAULT_API_KEY = os.environ.get("FLEXIAPI_API_KEY", "no_secret_at_all")
ALGORITHM = "SHA-256"


def _request(base, path, method, api_from, api_key, payload=None):
    url = base if base.endswith("/") else base + "/"
    url += path
    data = None
    headers = {"Accept": "application/json", "From": api_from, "x-api-key": api_key}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "replace")
        raise SystemExit(f"{method} {url} failed: {exc.code} {exc.reason} {detail}")
    except urllib.error.URLError as exc:
        raise SystemExit(f"{method} {url} failed: {exc.reason}")
    if not body:
        return {}
    return json.loads(body)


def _random_username(prefix):
    suffix = "".join(secrets.choice(string.digits) for _ in range(8))
    return f"{prefix}{suffix}"


def create(args):
    base = args.url
    token_response = _request(base, "account_creation_tokens", "POST", args.api_from, args.api_key)
    token = token_response.get("token")
    if not token:
        raise SystemExit(f"No creation token in response: {token_response}")

    username = args.username or _random_username(args.prefix)
    password = args.password or secrets.token_urlsafe(12)
    payload = {
        "username": username,
        "password": password,
        "algorithm": ALGORITHM,
        "account_creation_token": token,
    }
    account = _request(base, "accounts/with-account-creation-token", "POST", args.api_from, args.api_key, payload)
    account_id = account.get("id")

    result = {
        "username": username,
        "password": password,
        "domain": args.domain,
        "identity": f"sip:{username}@{args.domain}",
        "id": account_id,
    }
    if args.export:
        infix = f"{args.slot}_" if args.slot else ""
        print(f"export SQUISH_SIP_{infix}USER={shlex.quote(username)}")
        print(f"export SQUISH_SIP_{infix}PASS={shlex.quote(password)}")
        print(f"export SQUISH_SIP_{infix}DOMAIN={shlex.quote(args.domain)}")
        print(f"export SQUISH_ACCOUNT_{infix}ID={shlex.quote(str(account_id))}")
    else:
        print(json.dumps(result))


def delete(args):
    if not args.account_id or args.account_id == "None":
        return
    _request(args.url, f"accounts/{args.account_id}", "DELETE", args.api_from, args.api_key)


def main():
    parser = argparse.ArgumentParser(description="Provision FlexiAPI test accounts for Squish GUI tests")
    parser.add_argument("--url", default=DEFAULT_URL)
    parser.add_argument("--domain", default=DEFAULT_DOMAIN)
    parser.add_argument("--api-from", default=DEFAULT_FROM)
    parser.add_argument("--api-key", default=DEFAULT_API_KEY)
    sub = parser.add_subparsers(dest="command", required=True)

    create_parser = sub.add_parser("create")
    create_parser.add_argument("--prefix", default="squish_")
    create_parser.add_argument("--username")
    create_parser.add_argument("--password")
    create_parser.add_argument("--export", action="store_true")
    create_parser.add_argument("--slot", default="")
    create_parser.set_defaults(func=create)

    delete_parser = sub.add_parser("delete")
    delete_parser.add_argument("account_id")
    delete_parser.set_defaults(func=delete)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
