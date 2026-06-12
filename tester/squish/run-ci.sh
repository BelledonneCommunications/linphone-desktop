#!/bin/bash
set -u

if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -z "${INDBUS:-}" ]; then
    export INDBUS=1
    exec dbus-run-session -- bash "$0" "$@"
fi

SQUISH_BIN_PATH="${SQUISH_BIN_PATH:-/opt/squish-for-qt-9.0.1/bin}"
APPLICATION_NAME="${APPLICATION_NAME:-Linphone}"
EXECUTABLE_NAME="${EXECUTABLE_NAME:-linphone}"
SQUISH_LANGS="${SQUISH_LANGS:-en fr nl de}"
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
    python3 tester/squish/tools/seed_config.py c A --conference
    python3 tester/squish/tools/seed_config.py d B --conference
    python3 tester/squish/tools/seed_setting.py set-tp-show --ui assistant_hide_third_party_account=0
    python3 tester/squish/tools/seed_setting.py set-tp-hide --ui assistant_hide_third_party_account=1
    python3 tester/squish/tools/seed_setting.py set-ca-show --ui assistant_hide_create_account=0
    python3 tester/squish/tools/seed_setting.py set-ca-hide --ui assistant_hide_create_account=1
    python3 tester/squish/tools/seed_setting.py set-chat-show --slot A --ui disable_chat_feature=0
    python3 tester/squish/tools/seed_setting.py set-chat-hide --slot B --ui disable_chat_feature=1
    python3 tester/squish/tools/seed_setting.py set-meet-show --slot A --ui disable_meetings_feature=0 --proxy audio_video_conference_factory_uri=sip:conference-factory@conf.example.org
    python3 tester/squish/tools/seed_setting.py set-meet-hide --slot B --ui disable_meetings_feature=1
    python3 tester/squish/tools/seed_setting.py set-menu-show --slot A --ui hide_settings=0 --ui hide_account_settings=0 --ui disable_call_recordings_feature=0
    python3 tester/squish/tools/seed_setting.py set-menu-hide --slot B --ui hide_settings=1 --ui hide_account_settings=1 --ui disable_call_recordings_feature=1
    python3 tester/squish/tools/seed_setting.py set-sip-show --slot A --ui hide_sip_addresses=0
    python3 tester/squish/tools/seed_setting.py set-sip-hide --slot B --ui hide_sip_addresses=1
    python3 tester/squish/tools/seed_setting.py set-cf-show --slot A --ui disable_call_forward=0
    python3 tester/squish/tools/seed_setting.py set-cf-hide --slot B --ui disable_call_forward=1
    python3 tester/squish/tools/seed_setting.py set-bc-show --slot A --ui disable_broadcast_feature=0 --ui disable_meetings_feature=0 --proxy audio_video_conference_factory_uri=sip:conference-factory@conf.example.org
    python3 tester/squish/tools/seed_setting.py set-bc-hide --slot B --ui disable_broadcast_feature=1 --ui disable_meetings_feature=0 --proxy audio_video_conference_factory_uri=sip:conference-factory@conf.example.org
    python3 tester/squish/tools/seed_setting.py set-cli-show --slot A --ui disable_command_line=0
    python3 tester/squish/tools/seed_setting.py set-cli-hide --slot B --ui disable_command_line=1
    "$SQUISH_BIN_PATH/squishserver" --config removeAUT "$APPLICATION_NAME" >/dev/null 2>&1 || true
    "$SQUISH_BIN_PATH/squishserver" --config addAUT "$APPLICATION_NAME" "$AUT_DIR"
    "$SQUISH_BIN_PATH/squishserver" --daemon
    sleep 3
    RUN_LOG="$REPORTS_DIR/$LANG_CODE.log"
    "$SQUISH_BIN_PATH/squishrunner" --testsuite "$SUITE" --reportgen "html,$REPORTS_DIR/$LANG_CODE" --reportgen stdout --exitCodeOnFail 1 2>&1 | tee "$RUN_LOG"
    RC=${PIPESTATUS[0]}
    if [ "$RC" != "0" ]; then
        RESULT=$RC
        echo ""
        echo "::::::::::: SQUISH FAILURES in language '$LANG_CODE' :::::::::::"
        grep -iE "[[:space:]](FAIL|ERROR|FATAL)[[:space:]]" "$RUN_LOG" | grep -ivE "Number of"
        echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
    fi
    "$SQUISH_BIN_PATH/squishserver" --stop >/dev/null 2>&1 || true
done

python3 tester/squish/tools/account_manager.py delete "${SQUISH_ACCOUNT_A_ID:-}" 2>/dev/null || true
python3 tester/squish/tools/account_manager.py delete "${SQUISH_ACCOUNT_B_ID:-}" 2>/dev/null || true
echo "Squish tests finished with code $RESULT."
exit $RESULT
