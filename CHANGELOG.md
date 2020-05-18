# Changelog

## 4.2.0 - Unknown

### Features

- Improved general video/audio quality.
- Echo cancellation more efficient.
- `OpenH264` codec can be downloaded and used in the application from Cisco website.
- Improve High DPI Displays support for 4K screens.
- The fullscreen mode is show on the current call screen
- Detect audio/video hardware changes while using settings.
- Updatable audio/video devices while in call.

- Add an option to show Dialpad automatically.
- Dialpad supports A, B, C and D keys.
- Dialpad supports keyboard when having a focus by hovering mouse.
- Play a sound when DTMF is sent.

- Add an option to keep windows in background when a call is received.
- Add an option to allow Linphone to be lauched with the system (autostart).
- Add an option to play sound notification when an incoming chat message is received.
- Add Call utilities in Fullscreen mode (medias settings, security, mutable speaker)
- Capture and playback gains can be changed in settings with sliders.
- Conference participants are mutable by clicking on them
- Add the possibility to record calls automatically.
- Move logs folder without restart.
- Add caller/callee on saved files.

- Add a `CLI` function in order to support `URI handlers`. Help is available with `linphone --cli-help`. (See: https://wiki.linphone.org/xwiki/wiki/public/view/Linphone/URI%20Handlers%20%28Desktop%20only%29/)
- Timeline uses current proxy config info and show data only on selected profile.
- Tooltips can be show in multiple lines
- Display the name of the caller in incoming notifications
- Notifications are shown in all available screens
- Display unread message count in system tray icon/mac app icon.
- Display unread chat message count in `Manage Accounts` dialog and in `Main Window`.
- Add a media parameters dialog in the `Call View` to selected devices and set volume.
- Display a spinner when a message is sending.
- Disable screensaver on fullscreen video call.
- New logo, icons and installer assets.

- NSIS (Windows), DMG (MacOsX) and Appimage (Linux) packaging.
- Supports chinese, danish, french, english, german, hungarian, italian, japanese, lithuanian, portuguese, russian, spanish, swedish, turkish, ukrainian from community contributions.

- Use Native BZip2 instead of Embedded Minizip to extract codec.
- App Nap avoiding for MacOs.
- Simplify building process.

### Fixes

- Remove the use of `:` separator when a file is saved on Windows.
- Avoid mark `as read` on selected chat room if window is not active.
- Search box in main page will not reset its text when clicking on it
- More stable account authentifications
- Message status behaviour : Resuming status when changing logs, cursor shapes updates, bind the resend message action to error icon
- Apple permissions that could lead to mute microphone

### Removed

- Prepare.py configuration
- Remove useless splashscreen.
- Minizip dependencies
- Flatpack support

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
