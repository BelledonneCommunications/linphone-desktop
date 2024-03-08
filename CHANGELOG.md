# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## 5.2.2 - 2024-03-08

### Fixed
- Audio latency and bad echo behavior when going to media settings while being in call.
- About panel in readonly
- Wrong day offset in start date when scheduling a conference.
- Empty route can now be set in account settings.
- Network remote file can be used in chat attachment on Windows.
- Crash on forwarding a message to a new secure chat room.
- URI handlers and remote provisioning.
- Avoid to remove file on cancelling upload and fix cancelling file transfers.
- Update SDK to 5.3.30.

### Added
- '[ui] logs_max_size' : option to set the max size of one log file.
- '[ui] notification_origin' : option to specify where to display notifications (only supported: 0=bottom-right and 1=top-right).
- '[ui] systray_notification_blink' : option to activate/deactivate the blinking systray on unread notifications.
- '[ui] systray_notification_global' : option to display notification number from all accounts or only selected.
- '[ui] systray_notification_filtered' : option to filter the notification number (not count if chat room is muted).

## 5.2.1 - 2024-02-01

### Fixed
- URI handlers when no domain are provided like tel:number.
- Empty page on first date in date picker.
- Ephemeral deactivation while restarting it.
- Fix rates on capture audio (SDK).
- Update SDK to 5.3.14.

### Added
- Remove trailing newlines in smart search bar.

## 5.2.0 - 2023-12-22

### Fixed
- Download path and emojis size settings
- Mac emoji font.
- Better SVG preview in thumbnails.
- Unstable forward message menu.
- Display all call logs on default account.
- Avoid sending composing when openning chat.
- Crashes.
- Double chat rooms.
- Update SDK to 5.3.1

### Added
- Dedicated call history view.
- Chat reactions
- Update UI layouts.
- Spellchecker
- LDAP search with multi-criteria.
- Export Desktop entry from menu for Linux.

## Removed
- Call events from chats.
- Missed call count in application side (done by SDK).

## 5.1.3 - Undefined

### Fixed
- Wrong dates from DatePicker.
- Update SDK to 5.2.98
- Date from scheduling a meeting from chat room.

## 5.1.2 - 2023-08-25

### Fixed
- Mac Freeze on Active Speaker.
- Apply Accessibility workaround on all systems.
- Null access on QML object while being in fullscreen.

## 5.1.1 - 2023-08-24

### Fixed
- Windows freeze on Accessibility and with Qt < 5.15.10
- Update SDK to 5.2.97

## 5.1.0 - 2023-08-23

### Fixed
- Primary color for links in chat.
- Bubble chat layout.
- Camera stickers and conference layout stabilization.
- Robot voice with some devices (SDK fix).
- Crash after adding an account (SDK fix).
- Smart search bar behavior on empty text and focus changing.

### Added
- VFS Encryption.
- File viewer in chats (Image/Animated Image/Video/Texts/Pdf) with the option to export the file for VFS mode.
- Accept/decline CLI commands.
- Colored Emojis with its own font family.
- Option to set RLS URI in settings.
- Option to display only usernames when showing SIP addresses.
- Option to change the max results of the Magic Search bar.
- OAuth2 connection to retrieve remote provisioning (Experimental and not usable without configuration).
- Create an account with a manual validation (external captcha as of 5.1.0).
- Add/View contact from a message.
- Mute option for each chatrooms.
- New Chat Layout.
- Display last seen for contacts.
- New language support: Czech
- An option to set dial prefix and its use on numbers.
- Fetch remote provisioning from URI handler and with confirmation.
- Emojis picker.
- Text edit in chat can now understand rich texts.
- Create thumbnails into memory instead of disk.
- Display video thumbnails.
- Crop thumbnail and pictures if distored.
- Enable registration from accounts list.
- Update SDK to 5.2.95

### Removed
- Picture zoom on mouse over.

## 5.0.18 - 2023-06-16

### Fixed
- Robot voice with some devices (SDK fix).
- Crash from Lime db failure (SDK fix).
- Loading optimization (SDK fix).
- Update SDK to 5.2.75

## 5.0.17 - 2023-06-01

### Fixed
- Section date timezone and conferences timezone.
- Couldn't select the default account without selecting another one before.
- Display a message about not having a configured account instead of displaying the local one. Local address can still be accessible from settings if activated.
- Display Assistant at home if no account has been set.
- Update SDK to 5.2.67 (Mac crash on resources)

## 5.0.16 - 2023-05-12

### Fixed
- Section date timezone in chat.
- Use custom font for chat compose area.
- Calling conference from history.
- Speaking border display.
- Replace double click on avatar by a simple click for copying address into the SmartSearchBar.
- Update SDK to 5.2.60 (Active Speaker fix)

## 5.0.15 - 2023-04-11

### Fixed
- Fix using only username in URI handlers.
- Chat flickering on load.
- Portait thumbnails.
- Color of busy indicator when the chat is loading.
- Incoming ephemerals weren't removed without reloading chat rooms.
- Update SDK to 5.2.42

### Added
- New language support: Czech
- Multiple files can be selected as attachement.

## 5.0.14 - 2023-03-16

## Fixed
- Downgrade Qt back to 5.15.2 because of Qt commercial licence that break other GPL licences.
- Show file extension image instead of thumbnails if image's size factor is too low/high.
- Update SDK to 5.2.35 (ZLib vulnerability).

## 5.0.13 - 2023-03-13 - postprone to 5.0.14

### Fixed
- Conference layout refreshing on creation.
- Crash and display of local conferences.
- Crash on chat rooms with default account.
- Show display name for local accounts.
- Update SDK to 5.2.32

## 5.0.12 - 2023-03-01 - postprone to 5.0.14

### Fixed
- Some case of unwanted settings folders creation.
- Replace black thumbnails that contains transparency by white color.
- Unusable Contact sheet.
- Update SDK to 5.2.28 (cleanup orphan NAT sections and race condition on MSTicker threads).

## 5.0.11 - 2023-02-24 - postprone to 5.0.14

### Fixed
- Crash on ending call in conference.
- Icon transparency generations on icon.ico
- Remove duplicated nat policies.
- Remove unadmin feature to self because of not fully supported.
- Save Stun/Turn proxy configuration.
- Crash after showing participant devices.
- Display of non-Ascii avatar
- Switch off camera at startup.
- Upgrade Qt to 5.15.12
- Update SDK to 5.2.24 (Fix unresponsive video conference on Mac/Windows)

## 5.0.10 - 2023-02-02

### Fixed
- Remove blank notification when declining incoming call.
- Remove blank page when opening calls window and add a waiting step while connecting to call.
- Camera activation issue based on call status.
- Crash when editing contacts from chat.
- Contacts synchronization on creation.
- Contact menu in secure chats.
- Remove FFMPEG from dependencies as it is no more needed.

## 5.0.9 - 2023-01-31

### Fixed
- Display hidden scrollbars.
- Display hidden error icon on messages.
- Display recordings page on Mac.
- Update SDK to 5.2.19 (fix crash)

## 5.0.8 - 2023-01-20

### Fixed
- Qt 5.12 compatibility on recordings.

## 5.0.7 - 2023-01-19

### Added
- Interactive preview in call:
	* Movable on holding mouse's left click.
	* Resizeable on mouse's wheel.
	* Reset on mouse's right click (first for size if changed, second for position)
- Hide the active speaker from the mini views.
- Display recordings list from the burger menu.

### Fixed
- Mini views layout on actives speaker.
- Set 1 month to default message expires.
- User-agent format compliance
- Update SDK to 5.2.15

## 5.0.6 - 2023-01-10

### Fixed
- URI Handlers to a conference.
- Display application icon and estimated size in Windows programs list.

## 5.0.5 - 2023-01-09

### Fixed
- Crash at startup.
- Deploy missing OpenSSL libraries on Windows (fix blank message on image url).
- Update SDK to 5.2.10

## 5.0.4 - 2022-12-28

### Fixed
- Volume gauge in multimedia parameters while being in call.

## 5.0.3 - 2022-12-21

### Fixed
- Missing SetThreadDescription entry point on Windows 7/8 (SDK update)
- Add more margin on message's IMDN that was behind the icon menu in chats.
- Remove JSON dependencies on unused Flexiapi.
- Crash at startup about missing contact address on account (SDK fix)

## 5.0.2 - 2022-12-13

### Fixed
- Default Language didn't match with the system language (Qt bug).

## 5.0.1 - 2022-12-09

### Fixed
- RF3987 to allow IRI parsing in chats.
- Image display in chats from an URL.
- Display a notification of all kind of messages.

## 5.0.0 - 2022-12-07

### Added
- Video conference and iCalendars.
- Make a meeting directly from a group chat.
- New call layouts.
- Display a waiting room before going into a conference.
- Log viewer.
- Read contacts from all friends lists.
- Option to set the display name in "using an account" tab of assistant.
- Long pressed buttons.
- Date and Time pickers.
- Phone dialpad on main window.
- Animated file in chats/notifications.
- Round progress bar for transferring a file and allow to cancel it.
- Hide all accounts if their custom parameter 'hidden' is set to 1.
- Right-click on a timeline will show a slide menu to do actions on the timeline.
- Post quantum ZRTP.
- Windows stack trace dumps into logs on crash.
- Mark as Read synchronized between devices.
- Merge messages into one notification to avoid spam.
- Design overhaul on calls.
- Audio devices can be changed while being in call.
- Use a cryptographic checksum when downloading openH264 from CISCO (Update to 2.2.0)

### Fixed
- Crash on exit.
- Crash when using no account.
- Many Windows crashs (camera, incall)
- Memory stability.
- Clean 3 chat behaviors : Leave chat room (in group info section of conversation menu), erase history (in conversation's menu), delete chat room (in slide menu, or if chat room is empty and left)
- On Mac, close windows instead of minimizing them.
- Running application detection on Install/Uninstall.
- SVG Icons in better quality.
- Event timestamps.
- Optimizations and more minor fixes.

## 4.4.10 - 2022-09-20

### Fixes
- Lime exceptions because of unknown boundaries.
- AppimageTool update for code signing.

## 4.4.9 - 2022-08-29

### Fixes
- Update SDK to fix a crash on startup due to a test on a removed participant device.
- Use default values for new accounts in settings panel.

### Added
- Add 'sip' scheme in authentication popup.

## 4.4.8 - 2022-07-05

### Fixes
- Display name are based on friends (coming from local or LDAP server) and caller address only.
- Running application detection for uninstalling.

## 4.4.7 - 2022-07-01

### Fixes
- When receiving a SIP URL, copy it in Smart search bar instead of openning conversation.
- Update SDK to prepare video conference and improve DTLS handshakes.

## 4.4.6 - 2022-06-14

### Fixed
- Url version check and selection synchronisation.
- Show display name of the caller if it exists instead of call logs.

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
