# Change Log
All notable changes to this project will be documented in this file.

Group changes to describe their impact on the project, as follows:

    Added for new features.
    Changed for changes in existing functionality.
    Deprecated for once-stable features removed in upcoming releases.
    Removed for deprecated features removed in this release.
    Fixed for any bug fixes.
    Security to invite users to upgrade in case of vulnerabilities.

## [6.1.0] - Unreleased

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