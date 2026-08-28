# Change Log
All notable changes to this project will be documented in this file.

Group changes to describe their impact on the project, as follows:

    Added for new features.
    Changed for changes in existing functionality.
    Deprecated for once-stable features removed in upcoming releases.
    Removed for deprecated features removed in this release.
    Fixed for any bug fixes.
    Security to invite users to upgrade in case of vulnerabilities.

## [6.2.2] - 2026-08-28

### Fixed
- Crash in calls window caused by access to readonly property
- Generated RELEASE file for Linux platform

### Changed
- SDK update

## [6.2.1] - 2026-08-20

### Added
- New settings : 
    - noise suppressor
    - call view rendering in background
- Recording list from calls acessible in the app with audio/video player

### Fixed
- Duplication of participants stickers
- Playback/capture auto switch glitch in multimedia parameters
- Crash when Windows notification deleted
- Account status colors for accessibility
- Account presence

### Changed
- SDK version is now 5.5.16

## [6.2.0] - 2026-07-15

### Added
- Edition and deletion of an existing message
- Meeting export
- Accessibility improvements (information popup annoucement, labels for search bar, notifications)
- Direct access to medias and documents from the contact page
- Access to a meeting chat from the call history
- Recording access from account menu
- Scroll to original message when clicking on reply message
- New parameters : 
    - hide the past meetings

### Fixed
- Crashes (in meetings participants, in chat messages, on call end)
- Deleted files from an ephemeral message are now also deleted from the download folder
- UI fixes (chat message formatting, more error messages, meeting list view, download link on new Linphone version notification, items position and margins...)
- Update screen list in screencast panel when a screen is connected/disconnected
- Mac: fix showing the main window after it was closed, click escape to leave full screen mode
- Device changing in waiting room before entering a meeting
- Remove account data from the linphonerc file when disconnected
- Accessibility (screen reader and focus on main page, magic search bar, calls, contacts, settings, dialer, modal, combobox, call window, popup, notification badge; various default focus item; auto-scroll in settings; navigation on page tab bar)

### Changed
- Unification of URI handling with a unique scheme
- Remote provisioning does not require to restart the app anymore
- SDK version is now 5.5.0

### Known issues
- CardDAV by remote provisioning : address book may not be displayed in the contact list and in the contacts settings
- Chat messages are still received even when the account is disconnected, only the notification will be hidden and the sound will not be played
- Wayland does not support screen sharing for full screen (black screen displayed), only a window can be shared

## [6.1.2] - 2026-04-03

### Added
- New setting to enable or disable auto check for new version on start
- Accessibility improvements (visible focus on buttons to facilitate key navigation, start call by pressing Enter...)

### Fixed
- UI improvements and fixes
- Crash and bug fixes
- Notifications stealing focus on MacOS

### Changed
- Handle both arm64 and Intel compilations for MacOS
- SDK version is now 5.4.104
- Qt version is now 6.10.2 (Qt < 6.9 is deprecated because of the emojis rendering)


## [6.1.1] - 2026-02-25

### Added
- Configuration : The app now supports multiple commands in the same file (for calling a command just after account configuration)
- New parameters : 
    - hide the content of a new received message
    - choose the folder of the attachments

### Fixed
- Crash in chat due to residual chats
- Vulnerability in some texts rendered in rich text (/!\ Some emojis could not be rendered well if Qt < 6.9.0 is used)
- Notifications display on MacOS if the app is running in the background
- Key navigation improvement

### Changed
- Get back to minimum supported Qt version 6.8.0 for MacOS 12 compatibility (further versions should not support it anymore)
- Liphone now supports MacOS Intel processors
- SDK version is now 5.4.88


## [6.1.0] - 2026-01-27

6.1.0 release is the complete version of the new Linphone Desktop with all features including chat
 
### Added
- Chat: chat with your contacts, including text messaging, voice recording, sharing files or medias
- Presence: get your friend's presence status as long as you both are in your contact list
- Translations: Linphone is now available in English, French, Chinese, Czech, German, Portuguese, Russian and Ukrainian thank's to the Weblate contributors
- Check for update : you will get a notification on start if a new version is available, and you can look for a new version from the help page
- Bugsplat integration: add Bugsplat database parameters to improve crash reporting.

### Fixed
- Fixed "End-to-end encrypted call" label while in conference, the call may be end-to-end encrypted but only to the conference server, not to all participants
- Audio device list : display the correct devices in multimedia settings according to their functions (capture / playback / video)

### Changed
- Minimum supported Qt version is now 6.10.0
- Removed QtMultimedia dependency


## [6.0.0] - 2025-04-17

6.0.0 release is a complete rework of Linphone Desktop, with only the call and contact list features availables

### Added
- Contacts trust: contacts for which all devices have been validated through a ZRTP call with SAS exchange are now highlighted with a blue circle (and with a red one in case of mistrust). That trust is now handled at contact level (instead of conversation level in previous versions).
- Security focus: security & trust is more visible than ever, and unsecure conversations & calls are even more visible than before.
- CardDAV: you can configure as many CardDAV servers you want to synchronize you contacts in Linphone (in addition or in replacement of native addressbook import).
- OpenID: when used with a SSO compliant SIP server (such as Flexisip), we support single-sign-on login.
- MWI support: display and allow to call your voicemail when you have new messages (if supported by your VoIP provider and properly configured in your account params).
- CCMP support: if you configure a CCMP server URL in your accounts params, it will be used when scheduling meetings & to fetch list of meetings you've organized/been invited to.
- Devices list: check on which device your sip.linphone.org account is connected and the last connection date & time (like on subscribe.linphone.org).

### Changed
- Separated threads: Contrary to previous versions, our SDK is now running in it's own thread, meaning it won't freeze the UI anymore in case of heavy work, thus reducing the number of ANR and greatly increasing the fluidity of the app.
- Asymmetrical video : you no longer need to send your own camera feed to receive the one from the remote end of the call, and vice versa.
- Call transfer: Blind & Attended call transfer have been merged into one: during a call, if you initiate a transfer action, either pick another call to do the attended transfer or select a contact from the list (you can input a SIP URI not already in the suggestions list) to start a blind transfer.
- Settings: a lot of them are gone, the one that are still there have been reworked to increase user friendliness.
- Default screen (between contacts, call history, conversations & meetings list) will change depending on where you were when the app was paused or killed, and you will return to that last visited screen on the next startup.
- Minimum supported Qt version is now 6.5.3
- Some settings have changed name and/or section in linphonerc file.