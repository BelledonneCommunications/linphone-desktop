# Changelog

## 4.2.0 - Unknown

### Features

- Add an autostart option in GUI settings.
- Add an option to play sound notification when an incoming chat message is received.
- Add an option to show TelKeypad automatically.
- Add an option to automatically record calls.
- Add an option to keep calls window in background.
- Add a CLI. Help is available with `linphone --cli-help`. (See: https://wiki.linphone.org/xwiki/wiki/public/view/Linphone/URI%20Handlers%20%28Desktop%20only%29/)
- Timeline uses current proxy config info.
- Display unread message count in system tray icon/mac app icon.
- Display unread chat message count in `Manage Accounts` dialog and in `Main Window`.
- Add a media parameters dialog in the `Call View` to selected devices and set volume.
- TelKeypad supports A, B, C and D keys.
- TelKeypad supports keyboard.
- OpenH264 codec can be download in the application.
- Remove useless splashscreen.
- Disable screensaver on fullscreen video call.
- Add caller/callee on saved files.
- Supports totally french, english, portuguese, russian, turkish, ukrainian.

### Fixes

- Display a busy indicator when a message is sent.
- Play a sound when DTMF is sent.
- Do not use `:` separator when a file is saved on Windows.
- Avoid mark as read on selected chat room if window is not active.

## 4.1.0 - 2017-07-19

### Features

- Add tooltips on `recording` and `screenshot` buttons in `Calls Window`.
- Show notifications on `recording` and `screenshot`.
- Show `XXX is typing...` in `Timeline` and `Chat View`.
- Handle correctly `SIGINT`.
- Handle clicks on SIP URI in chat messages.
- Show video framerate in `Calls Stats`.
- Add a `Logs` menu entry in `Settings Window`, it provides send, remove, activate buttons...
- Supports EXIF orientation for file transfer images preview.
- Echo canceller supports 48kHz.
- Better GUI when a proxy config is modified in `Settings Window`.

### Fixes

- Handle correctly ringer device changes in `Settings Window`.
- In `Video Settings`, display FPS field only in `custom preset` mode.
- Use now the directory containing user documents files for saved video/audio/screenshots.
- Update `Chat View` correctly if it is used in many windows.
- Update correctly selected language when app is restarted.
- Avoid a deadlock on Mac OS when a call ends in fullscreen mode.
- Application can be started from one binary only.
- Single instance is now supported with flatpak. (It uses D-Bus.)
