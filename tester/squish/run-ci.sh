#!/bin/bash
set -u

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -z "${INDBUS:-}" ]; then
    export INDBUS=1
    exec dbus-run-session -- bash "$0" "$@"
fi

SQUISH_BIN_PATH="${SQUISH_BIN_PATH:-/opt/squish-for-qt-9.0.1/bin}"
APPLICATION_NAME="${APPLICATION_NAME:-Linphone}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-linphone}"
SQUISH_LANGS="${SQUISH_LANGS:-en fr}"
SUITE="tester/squish/suites/cross-platform"

if [ -n "${SQUISH_LICENSE_URL:-}" ]; then
    LICENSE_HOST="${SQUISH_LICENSE_URL%%:*}"
    LICENSE_PORT="${SQUISH_LICENSE_URL#*:}"
    [ "$LICENSE_PORT" = "$LICENSE_HOST" ] && LICENSE_PORT=49345
    printf '{\n    "format": "floating",\n    "host": "%s",\n    "port": %s\n}\n' \
        "$LICENSE_HOST" "$LICENSE_PORT" > "$HOME/.squish-license"
fi

APPIMAGE=$(ls build/OUTPUT/Packages/*.AppImage | head -n1)
echo "Using AppImage $APPIMAGE"
AUT_ROOT=$(mktemp -d)
trap 'rm -rf "$AUT_ROOT"' EXIT
cp "$APPIMAGE" "$AUT_ROOT/Linphone.AppImage"
chmod +x "$AUT_ROOT/Linphone.AppImage"
( cd "$AUT_ROOT" && ./Linphone.AppImage --appimage-extract >/dev/null )
AUT_DIR="$AUT_ROOT/squashfs-root/usr/bin"
ln -sf "$EXECUTABLE_NAME" "$AUT_DIR/$APPLICATION_NAME"

export QT_QPA_PLATFORM=xcb
export QT_PLUGIN_PATH="$AUT_ROOT/squashfs-root/usr/plugins"
export QML_IMPORT_PATH="$AUT_ROOT/squashfs-root/usr/qml"
export QML2_IMPORT_PATH="$AUT_ROOT/squashfs-root/usr/qml"

eval "$(python3 tester/squish/tools/account_manager.py create --export --slot A)"
eval "$(python3 tester/squish/tools/account_manager.py create --export --slot B)"
export SQUISH_SIP_USER="$SQUISH_SIP_A_USER"
export SQUISH_SIP_PASS="$SQUISH_SIP_A_PASS"
export SQUISH_SIP_DOMAIN="$SQUISH_SIP_A_DOMAIN"
echo "Provisioned A=$SQUISH_SIP_A_USER@$SQUISH_SIP_A_DOMAIN (id $SQUISH_ACCOUNT_A_ID), B=$SQUISH_SIP_B_USER@$SQUISH_SIP_B_DOMAIN (id $SQUISH_ACCOUNT_B_ID)"

REPORTS_DIR="${SQUISH_REPORTS_DIR:-squish-reports}"
mkdir -p "$REPORTS_DIR"
RESULT=0
for LANG_CODE in $SQUISH_LANGS; do
    echo "=== running suite in language: $LANG_CODE ==="
    python3 tester/squish/tools/gen_translations.py "$LANG_CODE" > "$SUITE/shared/scripts/currentTranslations.js"
    export LINPHONE_FORCE_LANGUAGE="$LANG_CODE"
    export XDG_CONFIG_HOME=$(mktemp -d)
    export XDG_DATA_HOME=$(mktemp -d)
    export XDG_CACHE_HOME=$(mktemp -d)
    python3 tester/squish/tools/seed_config.py a A
    python3 tester/squish/tools/seed_config.py b B
    "$SQUISH_BIN_PATH/squishserver" --config removeAUT "$APPLICATION_NAME" >/dev/null 2>&1 || true
    "$SQUISH_BIN_PATH/squishserver" --config addAUT "$APPLICATION_NAME" "$AUT_DIR"
    "$SQUISH_BIN_PATH/squishserver" --daemon
    sleep 3
    "$SQUISH_BIN_PATH/squishrunner" --testsuite "$SUITE" --reportgen "html,$REPORTS_DIR/$LANG_CODE" --exitCodeOnFail 1 || RESULT=$?
    "$SQUISH_BIN_PATH/squishserver" --stop >/dev/null 2>&1 || true
done

python3 tester/squish/tools/account_manager.py delete "${SQUISH_ACCOUNT_A_ID:-}" 2>/dev/null || true
python3 tester/squish/tools/account_manager.py delete "${SQUISH_ACCOUNT_B_ID:-}" 2>/dev/null || true
echo "Squish tests finished with code $RESULT."
exit $RESULT
