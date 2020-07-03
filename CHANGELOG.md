# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## 4.3.0 - [Undefined]


## 4.2.1 - 2020-07-03

### Fixed
- Crash on authentifications
- Multiple Popups are no longer ignored and are open in a StackView.

## 4.2.0 - 2020-06-26

### Added

- Added a `CLI` function in order to support `URI handlers` from browsers. Help is available with `linphone --cli-help`. (See also: https://wiki.linphone.org/xwiki/wiki/public/view/Linphone/URI%20Handlers%20%28Desktop%20only%29/).
- Improved general audio/video quality thanks to better rate control algorithms in liblinphone and mediastreamer2.
- More efficient echo cancellation.
- `OpenH264` codec can be downloaded and used in the application from Cisco website.
- `G729` codec can be used in the application.
- Improved High DPI Displays support for 4K screens.
- On multiscreens, when choosing full screen mode during a call, the call screen open in the current screen. The old behaviour kept the call screen in the primary screen.
- Detect audio/video hardware changes while using settings.
- Updatable audio/video devices while in call.

- Added an option to automatically show Dialpad.
- Dialpad supports A, B, C and D keys.
- Dialpad supports keyboard when hovering on it.
- DTMF sound played when sent.

- Added an option to keep windows in background when a call is received.
- Added an option to allow Linphone to be launched automatically with the system (autostart).
- Added an option to play sound notification when an incoming chat message is received.
- Added Call tools in Fullscreen mode (medias settings, security, mutable speaker).
- Audio settings display the microphone being used and allow you to adjust capture and playback gains.
- Conference participants are mutable by clicking on them.
- Added the possibility to record calls automatically.
- Moved logs folder without restart.
- Added caller and callee information into file names of recordings.

- Enhanced interface for switching between multiple SIP accounts: the timeline now shows activity for the currently selected SIP account only.
- Timeline uses current proxy config info and show data only on selected profile.
- Tooltips can be shown in multiple lines.
- Display the name of the caller in incoming notifications.
- Notifications are shown in all available screens.
- Display unread message count in system tray (Linphone icon).
- Display unread chat message count and missed calls in `Manage Accounts` dialog and in `Main Window`. 
- Added a media parameter dialog in the `Call View` to select devices and set volume.
- Display a spinner when a message is being sent.
- Disabled screensaver on fullscreen video call.
- New logo, icons and installer assets.

- New Linux deployment (Appimage).
- Supports chinese, danish, french, english, german, hungarian, italian, japanese, lithuanian, portuguese, russian, spanish, swedish, turkish, ukrainian from community contributions.

- Use Native BZip2 instead of Embedded Minizip to extract `OpenH264` codec.
- App Nap avoiding for MacOs.
- Simplified building process.

### Changed

- Upgraded to use QT 5.12.
- Depends on linphone-sdk project (numerous direct submodules removed).
- License changed from GPLv2 to GPLv3.

### Fixed

- Removed `:` separator from file names of recordings because it is not allowed on Windows.
- Avoided mark `as read` on selected chat rooms if window is not active.
- Search box in main page will not reset text when clicking on it.
- More stable account authentifications.
- Message status behaviour : Resuming status when changing logs, cursor shapes updates, bind the resend message action to error icon.
- Apple permissions that could lead to muted microphone.
- Incoming call notification window (sometimes not showing).

### Removed

- `Prepare.py` configuration.
- Remove useless splashscreen.
- `Minizip` dependencies.
- `Flatpak` support.

## 4.1.0 - 2017-07-19

### Added

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

### Fixed

- Handle correctly ringer device changes in `Settings Window`.
- In `Video Settings`, display FPS field only in `custom preset` mode.
- Use now the directory containing user documents files for saved video/audio/screenshots.
- Update `Chat View` correctly if it is used in many windows.
- Update correctly selected language when app is restarted.
- Avoid a deadlock on Mac OS when a call ends in fullscreen mode.
- Application can be started from one binary only.
- Single instance is now supported with flatpak. (It uses D-Bus.)
