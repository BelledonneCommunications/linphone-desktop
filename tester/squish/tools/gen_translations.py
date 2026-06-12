#!/usr/bin/env python3
import json
import os
import sys
import xml.etree.ElementTree as ET

LANG_DIR = os.environ.get("LANG_TS_DIR", "Linphone/data/languages")


def load_ts(path):
    result = {}
    if not os.path.exists(path):
        return result
    root = ET.parse(path).getroot()
    for context in root.iter("context"):
        name = context.find("name")
        context_name = name.text if name is not None and name.text else ""
        for message in context.iter("message"):
            source = message.find("source")
            translation = message.find("translation")
            if source is None or source.text is None:
                continue
            if translation is None or translation.get("type") == "unfinished":
                continue
            if translation.text:
                result.setdefault(context_name, {})[source.text] = translation.text
    return result


def merge(base, overlay):
    for context_name, entries in overlay.items():
        base.setdefault(context_name, {}).update(entries)
    return base


def main():
    lang = sys.argv[1] if len(sys.argv) > 1 else "en"
    table = load_ts(os.path.join(LANG_DIR, "en.ts"))
    merge(table, load_ts(os.path.join(LANG_DIR, lang + ".ts")))
    sys.stdout.write("export var T = " + json.dumps(table, ensure_ascii=False) + ";\n")


if __name__ == "__main__":
    main()
