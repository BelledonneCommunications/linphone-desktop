/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef SETTINGS_CORE_H_
#define SETTINGS_CORE_H_

#include "model/setting/SettingsModel.hpp"
#include "tool/thread/SafeConnection.hpp"

#include <QCommandLineParser>
#include <QObject>
#include <QSettings>
#include <QVariantMap>

class SettingsCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	// Security
	Q_PROPERTY(bool vfsEnabled READ getVfsEnabled WRITE setVfsEnabled NOTIFY vfsEnabledChanged)

	// Call
	Q_PROPERTY(bool videoEnabled READ getVideoEnabled WRITE setVideoEnabled NOTIFY videoEnabledChanged)
	Q_PROPERTY(bool echoCancellationEnabled READ getEchoCancellationEnabled WRITE setEchoCancellationEnabled NOTIFY
	               echoCancellationEnabledChanged)
	Q_PROPERTY(bool autoDownloadReceivedFiles READ getAutoDownloadReceivedFiles WRITE setAutoDownloadReceivedFiles
	               NOTIFY autoDownloadReceivedFilesChanged)
	Q_PROPERTY(
	    int echoCancellationCalibration READ getEchoCancellationCalibration NOTIFY echoCancellationCalibrationChanged)
	Q_PROPERTY(bool automaticallyRecordCallsEnabled READ getAutomaticallyRecordCallsEnabled WRITE
	               setAutomaticallyRecordCallsEnabled NOTIFY automaticallyRecordCallsEnabledChanged)

	Q_PROPERTY(bool captureGraphRunning READ getCaptureGraphRunning NOTIFY captureGraphRunningChanged)

	Q_PROPERTY(QVariantList captureDevices READ getCaptureDevices NOTIFY captureDevicesChanged)
	Q_PROPERTY(QVariantList playbackDevices READ getPlaybackDevices NOTIFY playbackDevicesChanged)
	Q_PROPERTY(QVariantList ringerDevices READ getRingerDevices NOTIFY ringerDevicesChanged)
	Q_PROPERTY(QVariantList conferenceLayouts READ getConferenceLayouts NOTIFY conferenceLayoutsChanged)
	Q_PROPERTY(QVariantList mediaEncryptions READ getMediaEncryptions NOTIFY mediaEncryptionsChanged)

	Q_PROPERTY(float playbackGain READ getPlaybackGain WRITE setPlaybackGain NOTIFY playbackGainChanged)
	Q_PROPERTY(float captureGain READ getCaptureGain WRITE setCaptureGain NOTIFY captureGainChanged)

	Q_PROPERTY(QVariantMap captureDevice READ getCaptureDevice WRITE setCaptureDevice NOTIFY captureDeviceChanged)
	Q_PROPERTY(QVariantMap playbackDevice READ getPlaybackDevice WRITE setPlaybackDevice NOTIFY playbackDeviceChanged)
	Q_PROPERTY(QVariantMap ringerDevice READ getRingerDevice WRITE setRingerDevice NOTIFY ringerDeviceChanged)

	// Call Forward
	Q_PROPERTY(QString callForwardToAddress READ getCallForwardToAddress WRITE setCallForwardToAddress NOTIFY
	               callForwardToAddressChanged)

	// Network
	Q_PROPERTY(bool ipv6Enabled READ getIpv6Enabled WRITE setIpv6Enabled NOTIFY ipv6EnabledChanged)
	Q_PROPERTY(bool hideFps READ getHideFps WRITE setHideFps NOTIFY hideFpsChanged)

	// Advanced
	Q_PROPERTY(bool autoStart READ getAutoStart WRITE setAutoStart NOTIFY autoStartChanged)

	Q_PROPERTY(
	    QVariantMap conferenceLayout READ getConferenceLayout WRITE setConferenceLayout NOTIFY conferenceLayoutChanged)
	Q_PROPERTY(
	    QVariantMap mediaEncryption READ getMediaEncryption WRITE setMediaEncryption NOTIFY mediaEncryptionChanged)
	Q_PROPERTY(bool mediaEncryptionMandatory READ isMediaEncryptionMandatory WRITE setMediaEncryptionMandatory NOTIFY
	               mediaEncryptionMandatoryChanged)
	Q_PROPERTY(
	    bool createEndToEndEncryptedMeetingsAndGroupCalls READ getCreateEndToEndEncryptedMeetingsAndGroupCalls WRITE
	        setCreateEndToEndEncryptedMeetingsAndGroupCalls NOTIFY createEndToEndEncryptedMeetingsAndGroupCallsChanged)

	Q_PROPERTY(QStringList videoDevices READ getVideoDevices NOTIFY videoDevicesChanged)
	Q_PROPERTY(QString videoDevice READ getVideoDevice WRITE setVideoDevice NOTIFY videoDeviceChanged)
	Q_PROPERTY(int videoDeviceIndex READ getVideoDeviceIndex NOTIFY videoDeviceChanged)

	Q_PROPERTY(float micVolume MEMBER _dummy_int NOTIFY micVolumeChanged)

	Q_PROPERTY(bool logsEnabled READ getLogsEnabled WRITE setLogsEnabled NOTIFY logsEnabledChanged)
	Q_PROPERTY(bool fullLogsEnabled READ getFullLogsEnabled WRITE setFullLogsEnabled NOTIFY fullLogsEnabledChanged)
	Q_PROPERTY(bool crashReporterEnabled READ getCrashReporterEnabled WRITE setCrashReporterEnabled NOTIFY crashReporterEnabledChanged)
	Q_PROPERTY(QString logsEmail READ getLogsEmail)
	Q_PROPERTY(QString logsFolder READ getLogsFolder)
	Q_PROPERTY(QString ringtoneName READ getRingtoneFileName NOTIFY ringtoneChanged)
	Q_PROPERTY(QString ringtonePath READ getRingtonePath WRITE setRingtone NOTIFY ringtoneChanged)
	Q_PROPERTY(QString ringtoneFolder MEMBER mRingtoneFolder NOTIFY ringtoneChanged)
	Q_PROPERTY(bool dnd READ dndEnabled WRITE lEnableDnd NOTIFY dndChanged)
	Q_PROPERTY(bool isSaved READ isSaved WRITE setIsSaved NOTIFY isSavedChanged)

	Q_PROPERTY(
	    bool showAccountDevices READ showAccountDevices WRITE setShowAccountDevices NOTIFY showAccountDevicesChanged)

	static QSharedPointer<SettingsCore> create();
	SettingsCore(QObject *parent = Q_NULLPTR);
	SettingsCore(const SettingsCore &settingsCore);
	virtual ~SettingsCore();

	void setSelf(QSharedPointer<SettingsCore> me);
	void reset(const SettingsCore &settingsCore);

	QString getConfigPath(const QCommandLineParser &parser = QCommandLineParser());

	Q_INVOKABLE void setFirstLaunch(bool first);
	Q_INVOKABLE bool getFirstLaunch() const;

	Q_INVOKABLE void setDisplayDeviceCheckConfirmation(bool display);
	Q_INVOKABLE bool getDisplayDeviceCheckConfirmation() const;

	// Used to restore the last active index on launch
	Q_INVOKABLE void setLastActiveTabIndex(int index);
	Q_INVOKABLE int getLastActiveTabIndex();

	// Security. --------------------------------------------------------------------
	bool getVfsEnabled() {
		return mVfsEnabled;
	}
	void setVfsEnabled(bool enabled);

	bool getVfsEncrypted();
	void setVfsEncrypted(bool encrypted, const bool deleteUserData);

	// Call. --------------------------------------------------------------------

	bool getVideoEnabled() {
		return mVideoEnabled;
	}
	void setVideoEnabled(bool enabled);

	bool getEchoCancellationEnabled() {
		return mEchoCancellationEnabled;
	}
	void setEchoCancellationEnabled(bool enabled);

	bool getAutoDownloadReceivedFiles() {
		return mAutoDownloadReceivedFiles;
	}
	void setAutoDownloadReceivedFiles(bool enabled);

	bool getAutomaticallyRecordCallsEnabled() {
		return mAutomaticallyRecordCallsEnabled;
	}
	void setAutomaticallyRecordCallsEnabled(bool enabled);

	float getPlaybackGain() const;
	void setPlaybackGain(float gain);
	void setPlaybackGainFromModel(float gain);

	float getCaptureGain() const;
	void setCaptureGain(float gain);
	void setCaptureGainFromModel(float gain);

	QVariantList getCaptureDevices() const;
	void setCaptureDevices(QVariantList devices);
	QVariantList getPlaybackDevices() const;
	void setPlaybackDevices(QVariantList devices);
	QVariantList getRingerDevices() const;
	void setRingerDevices(QVariantList devices);
	QVariantList getConferenceLayouts() const;
	void setConferenceLayouts(QVariantList layouts);
	QVariantList getMediaEncryptions() const;
	void setMediaEncryptions(QVariantList encryptions);

	QVariantMap getCaptureDevice() const;
	void setCaptureDevice(QVariantMap device);
	QVariantMap getPlaybackDevice() const;
	void setPlaybackDevice(QVariantMap device);
	QVariantMap getRingerDevice() const;
	void setRingerDevice(QVariantMap device);
	QVariantMap getConferenceLayout() const;
	void setConferenceLayout(QVariantMap layout);
	QVariantMap getMediaEncryption() const;
	void setMediaEncryption(QVariantMap encryption);
	bool isMediaEncryptionMandatory() const;
	void setMediaEncryptionMandatory(bool mandatory);
	bool getCreateEndToEndEncryptedMeetingsAndGroupCalls() const;
	void setCreateEndToEndEncryptedMeetingsAndGroupCalls(bool endtoend);
	bool isSaved() const;
	void setIsSaved(bool saved);

	QString getVideoDevice() const {
		return mVideoDevice;
	}
	void setVideoDevice(QString device);
	int getVideoDeviceIndex() const;
	QStringList getVideoDevices() const;
	void setVideoDevices(QStringList devices);

	bool getCaptureGraphRunning();

	Q_INVOKABLE void startEchoCancellerCalibration();
	int getEchoCancellationCalibration() const;

	Q_INVOKABLE void accessCallSettings();
	Q_INVOKABLE void closeCallSettings();
	Q_INVOKABLE void updateMicVolume() const;

	// Call Forward. --------------------------------------------------------------------

	QString getCallForwardToAddress() {
		return mCallForwardToAddress;
	}
	void setCallForwardToAddress(QString address);

	// Network. --------------------------------------------------------------------

	bool getIpv6Enabled() {
		return mIpv6Enabled;
	}
	void setIpv6Enabled(bool enabled);

	// Advanced. --------------------------------------------------------------------

	bool getAutoStart() {
		return mAutoStart;
	}
	void setAutoStart(bool enabled);

	bool getHideFps() {
		return mHideFps;
	}
	void setHideFps(bool hide);

	bool getLogsEnabled() const;
	void setLogsEnabled(bool enabled);
	bool getFullLogsEnabled() const;
	void setFullLogsEnabled(bool enabled);
	bool getCrashReporterEnabled() const;
	void setCrashReporterEnabled(bool enabled);

	void setRingtone(QString path);
	QString getRingtoneFileName() const;
	QString getRingtonePath() const;

	Q_INVOKABLE void cleanLogs() const;
	Q_INVOKABLE void sendLogs() const;
	QString getLogsEmail() const;
	QString getLogsFolder() const;
	void setLogsFolder(QString folder);

	bool dndEnabled() const;
	void setDndEnabled(bool enabled);

	bool showAccountDevices() const;
	void setShowAccountDevices(bool show);

	bool getCardDAVMinCharForResearch() const;
	void setCardDAVMinCharForResearch(int min);

	bool isCheckForUpdateAvailable() const;
	Q_INVOKABLE void save();
	Q_INVOKABLE void undo();

	DECLARE_CORE_GETSET_MEMBER(bool, disableChatFeature, DisableChatFeature)
	DECLARE_CORE_GETSET_MEMBER(bool, disableMeetingsFeature, DisableMeetingsFeature)
	DECLARE_CORE_GETSET_MEMBER(bool, disableBroadcastFeature, DisableBroadcastFeature)
	DECLARE_CORE_GETSET_MEMBER(bool, hideSettings, HideSettings)
	DECLARE_CORE_GETSET_MEMBER(bool, hideAccountSettings, HideAccountSettings)
	DECLARE_CORE_GETSET_MEMBER(bool, disableCallRecordings, DisableCallRecordings)
	DECLARE_CORE_GETSET_MEMBER(bool, assistantHideCreateAccount, AssistantHideCreateAccount)
	DECLARE_CORE_GETSET_MEMBER(bool, assistantDisableQrCode, AssistantDisableQrCode)
	DECLARE_CORE_GETSET_MEMBER(bool, assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DECLARE_CORE_GETSET_MEMBER(bool, hideSipAddresses, HideSipAddresses)
	DECLARE_CORE_GETSET_MEMBER(bool, darkModeAllowed, DarkModeAllowed)
	DECLARE_CORE_GETSET_MEMBER(int, maxAccount, MaxAccount)
	DECLARE_CORE_GETSET_MEMBER(bool,
	                           assistantGoDirectlyToThirdPartySipAccountLogin,
	                           AssistantGoDirectlyToThirdPartySipAccountLogin)
	DECLARE_CORE_GETSET_MEMBER(QString, assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DECLARE_CORE_GETSET_MEMBER(QString, assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DECLARE_CORE_GETSET(bool, exitOnClose, ExitOnClose)
	DECLARE_CORE_GETSET(bool, syncLdapContacts, SyncLdapContacts)
	DECLARE_CORE_GETSET(QString, configLocale, ConfigLocale)
	DECLARE_CORE_GETSET(QString, downloadFolder, DownloadFolder)
	// Read-only
	DECLARE_CORE_MEMBER(int, shortcutCount, ShortcutCount)
	DECLARE_CORE_MEMBER(QVariantList, shortcuts, Shortcuts)
	DECLARE_CORE_GETSET_MEMBER(bool, callToneIndicationsEnabled, CallToneIndicationsEnabled)
	DECLARE_CORE_GETSET_MEMBER(bool, disableCommandLine, DisableCommandLine)
	DECLARE_CORE_GETSET_MEMBER(QString, commandLine, CommandLine)
	DECLARE_CORE_GET_CONSTANT(QFont, emojiFont, EmojiFont)
	DECLARE_CORE_GET_CONSTANT(QFont, textMessageFont, TextMessageFont)
	// Theme
	DECLARE_CORE_GETSET_MEMBER(QString, themeMainColor, ThemeMainColor)
	DECLARE_CORE_GETSET_MEMBER(QString, themeAboutPictureUrl, ThemeAboutPictureUrl)

signals:

	// Security
	void vfsEnabledChanged();

	// Call
	void videoEnabledChanged();

	void echoCancellationEnabledChanged();
	void autoDownloadReceivedFilesChanged();

	void automaticallyRecordCallsEnabledChanged();

	void captureGraphRunningChanged(bool running);

	void lSetPlaybackGain(float gain);
	void playbackGainChanged(float gain);
	void lSetCaptureGain(float gain);
	void captureGainChanged(float gain);

	void captureDevicesChanged(const QVariantList &devices);
	void playbackDevicesChanged(const QVariantList &devices);
	void ringerDevicesChanged(const QVariantList &devices);

	// Network
	void ipv6EnabledChanged();

	// Call Forward
	void callForwardToAddressChanged();

	// Advanced
	void autoStartChanged();
	void hideFpsChanged();

	void conferenceLayoutsChanged(const QVariantList &layouts);
	void mediaEncryptionsChanged(const QVariantList &encryptions);

	void cardDAVMinCharForResearchChanged(int min);
	void cardDAVAddressBookSynchronized();

	void lSetCaptureDevice(QVariantMap device);
	void captureDeviceChanged(const QVariantMap &device);

	void ringtoneChanged();

	void lSetConferenceLayout(QVariantMap layout);
	void conferenceLayoutChanged();

	void mediaEncryptionChanged();

	void mediaEncryptionMandatoryChanged(bool mandatory);

	void createEndToEndEncryptedMeetingsAndGroupCallsChanged(bool endtoend);

	void isSavedChanged(bool saved);

	void lSetPlaybackDevice(QVariantMap device);
	void playbackDeviceChanged(const QVariantMap &device);

	void ringerDeviceChanged(const QVariantMap &device);

	void lSetVideoDevice(QString id);
	void videoDeviceChanged();
	void videoDevicesChanged();

	void echoCancellationCalibrationChanged();
	void micVolumeChanged(float volume);

	void logsEnabledChanged();
	void fullLogsEnabledChanged();
	void crashReporterEnabledChanged();

	void logsUploadTerminated(bool status, QString url);
	void logsFolderChanged(const QString &folder);

	void firstLaunchChanged(bool firstLaunch);
	void showVerifyDeviceConfirmationChanged(bool showVerifyDeviceConfirmation);

	void lastActiveTabIndexChanged();

	void dndChanged();

	void ldapConfigChanged();

	void lEnableDnd(bool value);

	void showAccountDevicesChanged(bool show);

protected:
	void writeIntoModel(std::shared_ptr<SettingsModel> model) const;
	void writeFromModel(const std::shared_ptr<SettingsModel> &model);

private:
	// Dummy properties (for properties that use values from core received through signals)
	int _dummy_int = 0;

	// Security
	bool mVfsEnabled;
	QVariantList mMediaEncryptions;
	QVariantMap mMediaEncryption;
	bool mMediaEncryptionMandatory;
	bool mCreateEndToEndEncryptedMeetingsAndGroupCalls;

	// Call
	bool mVideoEnabled;
	bool mEchoCancellationEnabled;
	bool mAutoDownloadReceivedFiles;
	bool mAutomaticallyRecordCallsEnabled;

	// Audio
	QVariantList mCaptureDevices;
	QVariantList mPlaybackDevices;
	QVariantList mRingerDevices;
	QVariantMap mCaptureDevice;
	QVariantMap mPlaybackDevice;
	QVariantMap mRingerDevice;

	QString mRingtonePath;
	QString mRingtoneFileName;
	QString mRingtoneFolder;

	QVariantList mConferenceLayouts;
	QVariantMap mConferenceLayout;

	// Video
	QStringList mVideoDevices;
	QString mVideoDevice;

	bool mCaptureGraphRunning;
	float mCaptureGain;
	float mPlaybackGain;
	int mEchoCancellationCalibration;

	// Network
	bool mIpv6Enabled;

	// Call Forward
	QString mCallForwardToAddress;

	// Advanced
	bool mAutoStart;
	bool mHideFps;

	// Debug logs
	bool mLogsEnabled;
	bool mFullLogsEnabled;
	bool mCrashReporterEnabled;
	QString mLogsFolder;
	QString mLogsEmail;

	// DND
	bool mDndEnabled;

	bool mIsSaved = true;
	bool mAutoSaved = false;
	QSettings mAppSettings;
	QSharedPointer<SafeConnection<SettingsCore, SettingsModel>> mSettingsModelConnection;

	// Account
	QString mDefaultDomain;
	bool mShowAccountDevices = false;

	// CardDAV
	int mCardDAVMinCharForResearch = 0;

	// Check update
	bool mIsCheckForUpdateAvailable = false;

	DECLARE_ABSTRACT_OBJECT
};
#endif
