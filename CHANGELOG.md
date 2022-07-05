# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 4.5 - [undefined]

### Added
- Video conference.
- Log viewer.
- Option to set the display name in "using an account" tab of assistant.
- Long pressed buttons.
- Phone dialpad on main window.

### Fixed
- Crash on exit.
- Memory stability.

## 4.4.8 - 2022-07-05

### Fixes
- Display name are based on friends (coming from local or LDAP server) and caller address only.
- Running application detection for uninstalling.
- Premission denied when downloading file in secure chat room (SDK fix).

## 4.4.7 - 2022-07-01

### Fixes
- When receiving a SIP URL, copy it in Smart search bar instead of openning conversation.
- Update SDK to prepare video conference and improve DTLS handshakes.

## 4.4.6 - 2022-06-14

### Fixed
- Url version check and selection synchronisation.
- Show display name of the caller if it exists instead of call logs.
- Display terminated rooms.

## 4.4.5 - 2022-06-06

### Fixed
- Chat rooms may be mark as read while hidden.

## 4.4.4 - 2022-06-01

### Fixed
- Revert ordering messages from receiving time.
- Some crashes on Wasapi.
- Update SDK to 5.1.41

## 4.4.3 - 2022-05-30

### Fixed
- Crash on searchs with special characters
- Update SDK to 5.1.38

## 4.4.2 - 2022-05-25

### Added
- Based on LinphoneSDK 5.1.36
- Add Sanitizer build.
- Version types selection for version checker.

### Fixed
- Order messages from receiving time.
- Fix H264 download URL on Linux.
- Hide Admin status in One-to-one chats.
- Encryption wasn't enabled after creating an account with lime url without having to restart the application.

## 4.4.1 - 2022-04-06

### Fixed
- Fix codec downloading on Windows and popup progress bar.

## 4.4.0 - 2022-04-04

### Added
- Features:
	* Messages features : Reply, forward (to contact, to a SIP address or to a timeline), Vocal record and play, multi contents, preview.
- Add a feedback on fetching remote provisioning when it failed.
- Option to enable message notifications.
- CPIM on basic chat rooms.
- Device name can be changed from settings.
- New event on new messages in chat and a shortcut to go to the end of chat if last message is not shown.
- Shortcut in Reply to message's origin.
- Allow redirected downloads (bzip2/OpenH264)
- Auto-download message files, editable in settings (10Mb as default)
- 64bits application on Windows
- Based on Linphone SDK 5.1

### Fixed
- Simplify filtering timelines with 2 modes (minimal or exhaustive) and on 3 kind of search : security level, simple/group chats, ephemerals.
- Sort timelines by taken account of unread events in chat rooms.
- Fix systemTrayIcon that could be cloned on each restart.
- Fix thumbnails display in notification.
- Fix errors on Action-Buttons on restart.
- Enable G729 on public builds.
- Take account of return key on Numpad.
- Huge messages are better shown and with less flickering.
- High CPU consumption on idle state.
- Hide deleted/terminated chat rooms.
- Adapt UserAgent with device name.
- Video freeze on network change.
- Support OpenGL 4.1 and GLSL 4.10.
- Fix some glitches on Apple M1.
- Audio errors in settings when using different audio format between input and output.
- Set default log size to 50MB
- Reduce ICE candidates on Windows.
- Show logs in console on Windows.
- Crash on the smart search bar.


## 4.3.2

### Fixed

- ALSA volumes can be view/changed while being in call.
- Remove constraints on actions (call/chat) that were based on friends capabilities.
- Unblock secure group chat activation.
- Unselect current contact if history call view is displayed.
- Show chat actions in history view.
- Group chat creation : If no groupchat capabilities has been found in recent contacts, ignore test on capability and display them.

## 4.3.1 - 2021-11-04

### Added

- Features:
	* New version behavior : Manual check for new version, option to activate the automatic check and a way to set the URL.
	* A banner is shown when copying text.
	* Options to enable standard and secure chats.
	* Add tunnel support if build.
	* Overhaul of color managment and use monochrome images.
	* Change Contact Edit and SIP Addresses selections to start a standard chat or a secure one.
	* Call history button in the timeline panel.
	* Timeout of incoming call notification is now based on `inc_timeout`
	* More actions in contact edit panel (call/video call).
	* Allow to make a readonly variable in configuration (only for enabling chats yet).
	
### Fixed

- Better quality of icons.
- Crash on start and on exit.
- Allow to use a secure chat room to be used when calling (set by context : encrypted call/secure chat enabled).
- History buttons that should not appear if chat room mode is not activated.
- Keep the fullscreen mode when receiving a notification.
- Clicking on the fullscreen action on the call window will go to the fullscreen if exists.
- Fix scrolling speed and add a cache in lists.
- Fix Mac crash by adding an option to deactivate mipmap.
- Add more translations.
- Mac: Enable automatic graphics switching indicating whether an OpenGL app may utilize the integrated GPU.
- Version checking that could request an update to older version.
- A crash on authentication with empty configs.
- Main search with UTF8
- When requested, remove all history of a chat room and not only desplayed entries.
- Fix missing qml variables.
- Add more debug logs.
- Use macqtdeploy when building in order to use binary without having enabling packaging.

## 4.3.0 - 2021-10-20

### Added

- Features:
	* Chat groups with administrator mode, participants management and devices display.
	* Secure chat rooms for 1-1 and group chat using LIME end-to-end encryption.
	* Ephemerals Chat rooms (per-participant mode).
	* Attended transfer.
	* LDAP integration: settings allow remote LDAP servers to be configured. Contacts can then be searched in the smart search bar, and during incoming call the display name of the caller is automatically retrieved from the LDAP server.
	* Address book connectors : custom plugins can now be imported from settings in order to be used to synchronize contacts.

- Enhance user experience :
	* Show subject in notifications for group chats.
	* Attended transfer.
	* Chat area is no more fixed but adapts to content.
	* Click on notification bubble in top left account lead to the call history view.
	* Double-Click on avatar in conversation to fill the smart search bar with the participant address.
	* Allow to hide or show the timeline panel.
	* Allow to hide or show empty chat rooms in settings.
	* Messages font can now be changed in settings.
	* Sort contact list using System Locale.
	* In fullscreen mode, the preview size can be changed by using mouse wheel.
	* Echo calibration in settings view.
	* Autostart for AppImage.
	* Add more tooltips.
	* Add a forgotten password link in assistant.

- Search and filtering features:
	* Search in timeline from subject/addresses.
	* Search in messages.
	* Filter timelines by the kind of chat rooms (1-1, group chats) and modes (secure and ephemerals).
	
- Chat room management:
	* Updatable subject by clicking on it.
	* Upgrade security level by authenticating participants.
	* Add more events in chat rooms like chat rooms status, participants updates, security level updates, ephemerals activations.

- In Chat, allow custom menu to appear by removing the repeating key when holding it. On Mac, there is an accent menu for this feature.
- Add URI handler configuration : `linphone-config` to fetch a configuration file.
- Fetch a configuration file from a CLI command/URI Handlers : 
    * sip:user@domain?method=call&fetch-config=base64(scheme://url)
    * linphone-config://url
    * linphone-config:fetch-config=base64(scheme://url)
    * linphone --fetch-config=scheme://url
    * linphone "<method> fetch-config=scheme://url"
- Options to audio codec can be used and stored.
- Devices can be selected in linphone configuration file from a regex rule.
- Opus can now use `packetlosspercentage` and `useinbandfec` configuration.
- A silence file have been added : `silence.mkv` and can be used to switch off some musics (hold_music).
- Use of new mediastreamer2 MSQOgl filter as video display backend (based on QQuickFramebufferObject).
- MSYS2 support for Windows.

### Fixed

- Cursor shape of mouse is changed when hovering on buttons.
- When clicking on a chat notification, it will close it.
- Persistent call bubble notifications.
- Fix on Missed calls and messages count bubbles.
- Unmatched room when using malformed username.
- Contact names handle special characters.
- UTF8 characters on Windows.
- Mark as Read only if in foreground.
- Show avatar and username once for a same kind of message.
- Load optimizations.
- Refactoring data modelisation and colors management.
- On Mac : Camera freeze and black screen when using third-party.
- Prevent opening call Window if the option to stay in background has been activated.
- Crash while searching contacts.
- Stop receiving messages when proxy has been deleted.
- Transfer menu of calls : Dynamic size for texts.
- XCode build wasn't fully supported.
- Sort languages in the UI settings.

## 4.2.5 - 2020-12-18

### Added

-iLBC support

### Fixed

- VP8 freeze
- Audio quality distortion
- OSX deployment target propagated to linphone SDK

## 4.2.4 - 2020-11-21

### Added

- Play DTMF when receiving it and show the Dialpad on outgoing call to allow sending DTMF
- Transport protocol deactivation has been replaced by not listening ports
- Show all call logs when clicking on the `previously` bar in the left panel
- A call log can be used to callback or add the contact in friends list

### Fixed

- Displaying names in UTF8
- Keep unsend typed message in memory when changing of chat room
- Log files have Qt logs
- Missing `sqlite3` backend
- Use the more generic `linphone` folder and not `Linphone` for installation
- Simplify build process to use install keyword
- Links errors like liblinphone++.so.10

## 4.2.3 - 2020-10-09

### Added

- Add support to tel and callto protocols
- Allow Pulseaudio to switch devices automatically. For example, it will mute all applications that have music when receive a call from Linphone.

### Fixed

- Contact name can contain special characters
- Avoid to reduce window if it is currently maximized when clicking on contacts
- Cleaner use of Windows registries

## 4.2.2 - 2020-07-30

### Fixed

- Crash on Opus

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
