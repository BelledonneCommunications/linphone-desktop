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

#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include "MediastreamerUtils.hpp"
#include <QFont>
#include <QObject>
#include <QVariantMap>
#include <linphone++/linphone.hh>

#include "tool/AbstractObject.hpp"

class SettingsModel : public QObject, public AbstractObject {
	Q_OBJECT

public:
	SettingsModel();
	virtual ~SettingsModel();

	static std::shared_ptr<SettingsModel> create();
	static std::shared_ptr<SettingsModel> getInstance();

	bool isReadOnly(const std::string &section, const std::string &name) const;
	std::string
	getEntryFullName(const std::string &section,
	                 const std::string &name) const; // Return the full name of the entry : 'name/readonly' or 'name'

	static const std::string UiSection;
	std::shared_ptr<linphone::Config> mConfig;

	bool getVfsEnabled() const;
	void setVfsEnabled(const bool enabled);

	bool getVideoEnabled() const;
	void setVideoEnabled(const bool enabled);

	bool getAutomaticallyRecordCallsEnabled() const;
	void setAutomaticallyRecordCallsEnabled(bool enabled);

	bool getEchoCancellationEnabled() const;
	void setEchoCancellationEnabled(bool enabled);

	// Audio. --------------------------------------------------------------------

	bool getIsInCall() const;
	void accessCallSettings();
	void closeCallSettings();

	void startCaptureGraph();
	void stopCaptureGraph();
	;
	void stopCaptureGraphs();
	void resetCaptureGraph();
	void createCaptureGraph();
	void deleteCaptureGraph();
	bool getCaptureGraphRunning();

	float getMicVolume();

	float getPlaybackGain() const;
	void setPlaybackGain(float gain);

	float getCaptureGain() const;
	void setCaptureGain(float gain);

	QStringList getCaptureDevices() const;
	QStringList getPlaybackDevices() const;
	QStringList getRingerDevices() const;

	QString getCaptureDevice() const;
	void setCaptureDevice(const QString &device);

	QString getPlaybackDevice() const;
	void setPlaybackDevice(const QString &device);

	QString getRingerDevice() const;
	void setRingerDevice(const QString &device);

	void startEchoCancellerCalibration();
	int getEchoCancellationCalibration() const;

	QStringList getVideoDevices() const;

	QString getVideoDevice() const;
	void setVideoDevice(const QString &device);

	bool getLogsEnabled() const;
	void setLogsEnabled(bool status);

	bool getFullLogsEnabled() const;
	void setFullLogsEnabled(bool status);

	static bool getLogsEnabled(const std::shared_ptr<linphone::Config> &config);
	static bool getFullLogsEnabled(const std::shared_ptr<linphone::Config> &config);

	QString getLogsFolder() const;
	void setLogsFolder(const QString &folder);
	static QString getLogsFolder(const std::shared_ptr<linphone::Config> &config);

	QString getLogsUploadUrl() const;
	void setLogsUploadUrl(const QString &url);

	void cleanLogs() const;
	void sendLogs() const;

	bool dndEnabled() const;
	static bool dndEnabled(const std::shared_ptr<linphone::Config> &config);
	void enableDnd(bool value);
	static void enableTones(const std::shared_ptr<linphone::Config> &config, bool enable);
	void enableRinging(bool enable);

	QString getLogsEmail() const;

	static const std::shared_ptr<linphone::FriendList> getCarddavListForNewFriends();
	static void setCarddavListForNewFriends(std::string listName);

	// UI
	DECLARE_GETSET(bool, disableChatFeature, DisableChatFeature)
	DECLARE_GETSET(bool, disableMeetingsFeature, DisableMeetingsFeature)
	DECLARE_GETSET(bool, disableBroadcastFeature, DisableBroadcastFeature)
	DECLARE_GETSET(bool, hideSettings, HideSettings)
	DECLARE_GETSET(bool, hideAccountSettings, HideAccountSettings)
	DECLARE_GETSET(bool, disableCallRecordings, DisableCallRecordings)
	DECLARE_GETSET(bool, assistantHideCreateAccount, AssistantHideCreateAccount)
	DECLARE_GETSET(bool, assistantDisableQrCode, AssistantDisableQrCode)
	DECLARE_GETSET(bool, assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DECLARE_GETSET(bool, onlyDisplaySipUriUsername, OnlyDisplaySipUriUsername)
	DECLARE_GETSET(bool, darkModeAllowed, DarkModeAllowed)
	DECLARE_GETSET(int, maxAccount, MaxAccount)
	DECLARE_GETSET(bool, assistantGoDirectlyToThirdPartySipAccountLogin, AssistantGoDirectlyToThirdPartySipAccountLogin)
	DECLARE_GETSET(QString, assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DECLARE_GETSET(QString, assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DECLARE_GETSET(bool, autoStart, AutoStart)
	DECLARE_GETSET(bool, exitOnClose, ExitOnClose)
	DECLARE_GETSET(bool, syncLdapContacts, SyncLdapContacts)
	DECLARE_GETSET(bool, ipv6Enabled, Ipv6Enabled)

signals:

	// VFS. --------------------------------------------------------------------
	void vfsEnabledChanged(bool enabled);
	void videoEnabledChanged(bool enabled);

	// Call. --------------------------------------------------------------------
	void echoCancellationEnabledChanged(bool enabled);
	void automaticallyRecordCallsEnabledChanged(bool enabled);

	void captureGraphRunningChanged(bool running);

	void playbackGainChanged(float gain);
	void captureGainChanged(float gain);

	void captureDevicesChanged(const QStringList &devices);
	void playbackDevicesChanged(const QStringList &devices);
	void ringerDevicesChanged(const QStringList &devices);

	void captureDeviceChanged(const QString &device);
	void playbackDeviceChanged(const QString &device);
	void ringerDeviceChanged(const QString &device);

	void showAudioCodecsChanged(bool status);

	void videoDevicesChanged(const QStringList &devices);
	void videoDeviceChanged(const QString &device);

	void micVolumeChanged(float volume);

	void logsEnabledChanged(bool status);
	void fullLogsEnabledChanged(bool status);

	void dndChanged(bool value);

private:
	void notifyConfigReady();
	MediastreamerUtils::SimpleCaptureGraph *mSimpleCaptureGraph = nullptr;
	int mCaptureGraphListenerCount = 0;

	static std::shared_ptr<SettingsModel> gCoreModel;

	DECLARE_ABSTRACT_OBJECT
};
#endif // SETTINGS_MODEL_H_
