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
    for message in root.iter("message"):
        source = message.find("source")
        translation = message.find("translation")
        if source is None or source.text is None:
            continue
        if translation is None or translation.get("type") == "unfinished":
            continue
        if translation.text:
            result[source.text] = translation.text
    return result


def main():
    lang = sys.argv[1] if len(sys.argv) > 1 else "en"
    table = load_ts(os.path.join(LANG_DIR, "en.ts"))
    table.update(load_ts(os.path.join(LANG_DIR, lang + ".ts")))
    sys.stdout.write("export var T = " + json.dumps(table, ensure_ascii=False) + ";\n")


if __name__ == "__main__":
    main()
