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

#include "SettingsCore.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

#include <QUrl>
#include <QVariant>

DEFINE_ABSTRACT_OBJECT(SettingsCore)

// =============================================================================

QSharedPointer<SettingsCore> SettingsCore::create() {
	auto sharedPointer = QSharedPointer<SettingsCore>(new SettingsCore(), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

SettingsCore::SettingsCore(QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
	auto settingsModel = SettingsModel::getInstance();
	assert(settingsModel);

	// Security
	mVfsEnabled = settingsModel->getVfsEnabled();

	// Call
	mVideoEnabled = settingsModel->getVideoEnabled();
	mEchoCancellationEnabled = settingsModel->getEchoCancellationEnabled();
	mAutoDownloadReceivedFiles = settingsModel->getAutoDownloadReceivedFiles();
	mDisplayNotificationContent = settingsModel->getDisplayNotificationContent();
	mAutomaticallyRecordCallsEnabled = settingsModel->getAutomaticallyRecordCallsEnabled();
	mRingtonePath = settingsModel->getRingtone();
	QFileInfo ringtone(mRingtonePath);
	if (ringtone.exists()) {
		mRingtoneFileName = ringtone.fileName();
		mRingtoneFolder = ringtone.absolutePath();
	} else {
		mRingtoneFileName = mRingtonePath.right(mRingtonePath.lastIndexOf(QDir::separator()));
		mRingtoneFolder = mRingtonePath.left(mRingtonePath.lastIndexOf(QDir::separator()));
	}

	// Network
	mIpv6Enabled = settingsModel->getIpv6Enabled();

	// Advanced
	mAutoStart = settingsModel->getAutoStart();
	mHideFps = settingsModel->getHideFps();

	// Audio
	mCaptureDevices = settingsModel->getCaptureDevices();
	mPlaybackDevices = settingsModel->getPlaybackDevices();
	mRingerDevices = settingsModel->getRingerDevices();
	mCaptureDevice = settingsModel->getCaptureDevice();
	mPlaybackDevice = settingsModel->getPlaybackDevice();
	mRingerDevice = settingsModel->getRingerDevice();

	mConferenceLayouts = LinphoneEnums::conferenceLayoutsToVariant();
	mConferenceLayout =
	    LinphoneEnums::toVariant(LinphoneEnums::fromLinphone(settingsModel->getDefaultConferenceLayout()));

	mMediaEncryptions = LinphoneEnums::mediaEncryptionsToVariant();
	mMediaEncryption =
	    LinphoneEnums::toVariant(LinphoneEnums::fromLinphone(settingsModel->getDefaultMediaEncryption()));

	mMediaEncryptionMandatory = settingsModel->getMediaEncryptionMandatory();
	mCreateEndToEndEncryptedMeetingsAndGroupCalls = settingsModel->getCreateEndToEndEncryptedMeetingsAndGroupCalls();

	mCaptureGain = settingsModel->getCaptureGain();
	mPlaybackGain = settingsModel->getPlaybackGain();

	// Video
	mVideoDevice = settingsModel->getVideoDevice();
	mVideoDevices = settingsModel->getVideoDevices();

	// Logs
	mLogsEnabled = settingsModel->getLogsEnabled();
	mFullLogsEnabled = settingsModel->getFullLogsEnabled();
	mCrashReporterEnabled = settingsModel->getCrashReporterEnabled();
	mLogsFolder = settingsModel->getLogsFolder();
	mLogsEmail = settingsModel->getLogsEmail();

	// DND
	mDndEnabled = settingsModel->dndEnabled();

	mDefaultDomain = settingsModel->getDefaultDomain();
	auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	if (currentAccount) {
		auto accountDomain = Utils::coreStringToAppString(currentAccount->getParams()->getDomain());
		mShowAccountDevices = (accountDomain == mDefaultDomain);
	}

	// Chat
	mEmojiFont = settingsModel->getEmojiFont();
	mTextMessageFont = settingsModel->getTextMessageFont();

	// Check for update
	mIsCheckForUpdateAvailable = settingsModel->isCheckForUpdateAvailable();

	// Ui
	INIT_CORE_MEMBER(DisableChatFeature, settingsModel)
	INIT_CORE_MEMBER(DisableMeetingsFeature, settingsModel)
	INIT_CORE_MEMBER(DisableBroadcastFeature, settingsModel)
	INIT_CORE_MEMBER(HideSettings, settingsModel)
	INIT_CORE_MEMBER(HideAccountSettings, settingsModel)
	INIT_CORE_MEMBER(DisableCallRecordings, settingsModel)
	INIT_CORE_MEMBER(AssistantHideCreateAccount, settingsModel)
	INIT_CORE_MEMBER(AssistantDisableQrCode, settingsModel)

	INIT_CORE_MEMBER(AssistantHideThirdPartyAccount, settingsModel)
	INIT_CORE_MEMBER(HideSipAddresses, settingsModel)
	INIT_CORE_MEMBER(DarkModeAllowed, settingsModel)
	INIT_CORE_MEMBER(MaxAccount, settingsModel)
	INIT_CORE_MEMBER(AssistantGoDirectlyToThirdPartySipAccountLogin, settingsModel)
	INIT_CORE_MEMBER(AssistantThirdPartySipAccountDomain, settingsModel)
	INIT_CORE_MEMBER(AssistantThirdPartySipAccountTransport, settingsModel)
	INIT_CORE_MEMBER(AutoStart, settingsModel)
	INIT_CORE_MEMBER(ExitOnClose, settingsModel)
	INIT_CORE_MEMBER(SyncLdapContacts, settingsModel)
	INIT_CORE_MEMBER(ConfigLocale, settingsModel)
	INIT_CORE_MEMBER(DownloadFolder, settingsModel)

	INIT_CORE_MEMBER(ShortcutCount, settingsModel)
	INIT_CORE_MEMBER(Shortcuts, settingsModel)
	INIT_CORE_MEMBER(CallToneIndicationsEnabled, settingsModel)
	INIT_CORE_MEMBER(CommandLine, settingsModel)
	INIT_CORE_MEMBER(DisableCommandLine, settingsModel)
	INIT_CORE_MEMBER(CallForwardToAddress, settingsModel)

	INIT_CORE_MEMBER(ThemeMainColor, settingsModel)
	INIT_CORE_MEMBER(ThemeAboutPictureUrl, settingsModel)
}

SettingsCore::SettingsCore(const SettingsCore &settingsCore) {
	// Security
	mVfsEnabled = settingsCore.mVfsEnabled;
	mMediaEncryptions = settingsCore.mMediaEncryptions;
	mMediaEncryption = settingsCore.mMediaEncryption;
	mMediaEncryptionMandatory = settingsCore.mMediaEncryptionMandatory;
	mCreateEndToEndEncryptedMeetingsAndGroupCalls = settingsCore.mCreateEndToEndEncryptedMeetingsAndGroupCalls;

	// Call
	mVideoEnabled = settingsCore.mVideoEnabled;
	mEchoCancellationEnabled = settingsCore.mEchoCancellationEnabled;
	mAutoDownloadReceivedFiles = settingsCore.mAutoDownloadReceivedFiles;
	mDisplayNotificationContent = settingsCore.mDisplayNotificationContent;
	mAutomaticallyRecordCallsEnabled = settingsCore.mAutomaticallyRecordCallsEnabled;

	// Audio
	mCaptureDevices = settingsCore.mCaptureDevices;
	mPlaybackDevices = settingsCore.mPlaybackDevices;
	mRingerDevices = settingsCore.mRingerDevices;
	mCaptureDevice = settingsCore.mCaptureDevice;
	mPlaybackDevice = settingsCore.mPlaybackDevice;
	mRingerDevice = settingsCore.mRingerDevice;

	mConferenceLayouts = settingsCore.mConferenceLayouts;
	mConferenceLayout = settingsCore.mConferenceLayout;

	// Video
	mVideoDevice = settingsCore.mVideoDevice;
	mVideoDevices = settingsCore.mVideoDevices;

	mCaptureGain = settingsCore.mCaptureGain;
	mPlaybackGain = settingsCore.mPlaybackGain;

	mEchoCancellationCalibration = settingsCore.mEchoCancellationCalibration;

	// Logs
	mLogsEnabled = settingsCore.mLogsEnabled;
	mFullLogsEnabled = settingsCore.mFullLogsEnabled;
	mCrashReporterEnabled = settingsCore.mCrashReporterEnabled;
	mLogsFolder = settingsCore.mLogsFolder;
	mLogsEmail = settingsCore.mLogsEmail;

	// DND
	mDndEnabled = settingsCore.mDndEnabled;

	// UI
	mDisableChatFeature = settingsCore.mDisableChatFeature;
	mDisableMeetingsFeature = settingsCore.mDisableMeetingsFeature;
	mDisableBroadcastFeature = settingsCore.mDisableBroadcastFeature;
	mHideSettings = settingsCore.mHideSettings;
	mHideAccountSettings = settingsCore.mHideAccountSettings;
	mHideFps = settingsCore.mHideFps;
	mDisableCallRecordings = settingsCore.mDisableCallRecordings;
	mAssistantHideCreateAccount = settingsCore.mAssistantHideCreateAccount;
	mAssistantHideCreateAccount = settingsCore.mAssistantHideCreateAccount;
	mAssistantDisableQrCode = settingsCore.mAssistantDisableQrCode;

	mAssistantHideThirdPartyAccount = settingsCore.mAssistantHideThirdPartyAccount;
	mHideSipAddresses = settingsCore.mHideSipAddresses;
	mDarkModeAllowed = settingsCore.mDarkModeAllowed;
	mMaxAccount = settingsCore.mMaxAccount;
	mAssistantGoDirectlyToThirdPartySipAccountLogin = settingsCore.mAssistantGoDirectlyToThirdPartySipAccountLogin;
	mAssistantThirdPartySipAccountDomain = settingsCore.mAssistantThirdPartySipAccountDomain;
	mAssistantThirdPartySipAccountTransport = settingsCore.mAssistantThirdPartySipAccountTransport;
	mExitOnClose = settingsCore.mExitOnClose;
	mSyncLdapContacts = settingsCore.mSyncLdapContacts;
	mIpv6Enabled = settingsCore.mIpv6Enabled;
	mAutoStart = settingsCore.mAutoStart;
	mConfigLocale = settingsCore.mConfigLocale;
	mDownloadFolder = settingsCore.mDownloadFolder;
	mShortcutCount = settingsCore.mShortcutCount;
	mShortcuts = settingsCore.mShortcuts;
	mCallToneIndicationsEnabled = settingsCore.mCallToneIndicationsEnabled;
	mCommandLine = settingsCore.mCommandLine;
	mDisableCommandLine = settingsCore.mDisableCommandLine;
	mCallForwardToAddress = settingsCore.mCallForwardToAddress;

	mDefaultDomain = settingsCore.mDefaultDomain;
	mShowAccountDevices = settingsCore.mShowAccountDevices;

	mRingtonePath = settingsCore.mRingtonePath;
	mRingtoneFileName = settingsCore.mRingtoneFileName;
}

SettingsCore::~SettingsCore() {
}

void SettingsCore::reloadSettings() {
	mustBeInLinphoneThread(getClassName());
	auto settingsModel = SettingsModel::getInstance();
	assert(settingsModel);

	// Security
	setVfsEnabled(settingsModel->getVfsEnabled());

	// Call
	setVideoEnabled(settingsModel->getVideoEnabled());
	setEchoCancellationEnabled(settingsModel->getEchoCancellationEnabled());
	setAutoDownloadReceivedFiles(settingsModel->getAutoDownloadReceivedFiles());
	setDisplayNotificationContent(settingsModel->getDisplayNotificationContent());
	setAutomaticallyRecordCallsEnabled(settingsModel->getAutomaticallyRecordCallsEnabled());
	setRingtone(settingsModel->getRingtone());

	// Network
	setIpv6Enabled(settingsModel->getIpv6Enabled());

	// Advanced
	setAutoStart(settingsModel->getAutoStart());
	setHideFps(settingsModel->getHideFps());

	// Audio
	setCaptureDevices(settingsModel->getCaptureDevices());
	setPlaybackDevices(settingsModel->getPlaybackDevices());
	setRingerDevices(settingsModel->getRingerDevices());
	setCaptureDevice(settingsModel->getCaptureDevice());
	setPlaybackDevice(settingsModel->getPlaybackDevice());
	setRingerDevice(settingsModel->getRingerDevice());

	setConferenceLayout(
	    LinphoneEnums::toVariant(LinphoneEnums::fromLinphone(settingsModel->getDefaultConferenceLayout())));

	setMediaEncryption(
	    LinphoneEnums::toVariant(LinphoneEnums::fromLinphone(settingsModel->getDefaultMediaEncryption())));

	setMediaEncryptionMandatory(settingsModel->getMediaEncryptionMandatory());
	setCreateEndToEndEncryptedMeetingsAndGroupCalls(settingsModel->getCreateEndToEndEncryptedMeetingsAndGroupCalls());

	setCaptureGain(settingsModel->getCaptureGain());
	setPlaybackGain(settingsModel->getPlaybackGain());

	// Video
	setVideoDevice(settingsModel->getVideoDevice());
	setVideoDevices(settingsModel->getVideoDevices());

	// Logs
	setLogsEnabled(settingsModel->getLogsEnabled());
	setFullLogsEnabled(settingsModel->getFullLogsEnabled());
	setCrashReporterEnabled(settingsModel->getCrashReporterEnabled());
	setLogsFolder(settingsModel->getLogsFolder());
	mLogsEmail = settingsModel->getLogsEmail();

	// DND
	setDndEnabled(settingsModel->dndEnabled());

	mDefaultDomain = settingsModel->getDefaultDomain();
	auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	if (currentAccount) {
		auto accountDomain = Utils::coreStringToAppString(currentAccount->getParams()->getDomain());
		setShowAccountDevices(accountDomain == mDefaultDomain);
	}

	// Chat
	mEmojiFont = settingsModel->getEmojiFont();
	mTextMessageFont = settingsModel->getTextMessageFont();

	// Check for update
	mIsCheckForUpdateAvailable = settingsModel->isCheckForUpdateAvailable();

	setDisableChatFeature(settingsModel->getDisableChatFeature());
	setDisableMeetingsFeature(settingsModel->getDisableMeetingsFeature());
	setDisableBroadcastFeature(settingsModel->getDisableBroadcastFeature());

	setHideSettings(settingsModel->getHideSettings());
	setHideAccountSettings(settingsModel->getHideAccountSettings());

	setDisableCallRecordings(settingsModel->getDisableCallRecordings());
	setAssistantHideCreateAccount(settingsModel->getAssistantHideCreateAccount());
	setAssistantDisableQrCode(settingsModel->getAssistantDisableQrCode());
	setAssistantHideThirdPartyAccount(settingsModel->getAssistantHideThirdPartyAccount());
	setHideSipAddresses(settingsModel->getHideSipAddresses());
	setDarkModeAllowed(settingsModel->getDarkModeAllowed());
	setMaxAccount(settingsModel->getMaxAccount());
	setAssistantGoDirectlyToThirdPartySipAccountLogin(
	    settingsModel->getAssistantGoDirectlyToThirdPartySipAccountLogin());
	setAssistantGoDirectlyToThirdPartySipAccountLogin(
	    settingsModel->getAssistantGoDirectlyToThirdPartySipAccountLogin());
	setAssistantThirdPartySipAccountDomain(settingsModel->getAssistantThirdPartySipAccountDomain());
	setAssistantThirdPartySipAccountTransport(settingsModel->getAssistantThirdPartySipAccountTransport());
	setAutoStart(settingsModel->getAutoStart());
	setExitOnClose(settingsModel->getExitOnClose());
	setSyncLdapContacts(settingsModel->getSyncLdapContacts());
	setConfigLocale(settingsModel->getConfigLocale());
	setDownloadFolder(settingsModel->getDownloadFolder());

	setCallToneIndicationsEnabled(settingsModel->getCallToneIndicationsEnabled());
	setCommandLine(settingsModel->getCommandLine());
	setDisableCommandLine(settingsModel->getDisableCommandLine());
	setCallForwardToAddress(settingsModel->getCallForwardToAddress());
	setThemeMainColor(settingsModel->getThemeMainColor());
	setThemeAboutPictureUrl(settingsModel->getThemeAboutPictureUrl());
}

void SettingsCore::setSelf(QSharedPointer<SettingsCore> me) {
	mustBeInLinphoneThread(getClassName());
	mSettingsModelConnection = SafeConnection<SettingsCore, SettingsModel>::create(me, SettingsModel::getInstance());

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureGraphRunningChanged, [this](bool running) {
		mSettingsModelConnection->invokeToCore([this, running] {
			mCaptureGraphRunning = running;
			emit captureGraphRunningChanged(running);
		});
	});

	// VFS
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::vfsEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() { setVfsEnabled(enabled); });
	});

	// Video Calls
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::videoEnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() { setVideoEnabled(enabled); });
	});

	// Echo cancelling
	mSettingsModelConnection->makeConnectToModel(
	    &SettingsModel::echoCancellationEnabledChanged, [this](const bool enabled) {
		    mSettingsModelConnection->invokeToCore([this, enabled]() { setEchoCancellationEnabled(enabled); });
	    });

	// IPV6
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ipv6EnabledChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() { setIpv6Enabled(enabled); });
	});

	// Call Forward
	mSettingsModelConnection->makeConnectToModel(
	    &SettingsModel::callForwardToAddressChanged, [this](const QString address) {
		    mSettingsModelConnection->invokeToCore([this, address]() { setCallForwardToAddress(address); });
	    });

	// Hide FPS
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::hideFpsChanged, [this](const bool hide) {
		mSettingsModelConnection->invokeToCore([this, hide]() { setHideFps(hide); });
	});

	// AutoStart
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::autoStartChanged, [this](const bool enabled) {
		mSettingsModelConnection->invokeToCore([this, enabled]() {
			bool emitSignal = mAutoStart != enabled;
			setAutoStart(enabled);
			if (emitSignal) emit autoStartChanged();
		});
	});

	// Auto download incoming files
	mSettingsModelConnection->makeConnectToModel(
	    &SettingsModel::autoDownloadReceivedFilesChanged, [this](const bool enabled) {
		    mSettingsModelConnection->invokeToCore([this, enabled]() { setAutoDownloadReceivedFiles(enabled); });
	    });

	// Auto download incoming files
	mSettingsModelConnection->makeConnectToModel(
	    &SettingsModel::displayNotificationContentChanged, [this](const bool enabled) {
		    mSettingsModelConnection->invokeToCore([this, enabled]() { setDisplayNotificationContent(enabled); });
	    });

	// Download folder
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::downloadFolderChanged, [this](const QString &folder) {
		mSettingsModelConnection->invokeToCore([this, folder]() { setDownloadFolder(folder); });
	});

	// Auto recording
	mSettingsModelConnection->makeConnectToModel(
	    &SettingsModel::automaticallyRecordCallsEnabledChanged, [this](const bool enabled) {
		    mSettingsModelConnection->invokeToCore([this, enabled]() { setAutomaticallyRecordCallsEnabled(enabled); });
	    });

	// Audio device(s)
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetCaptureDevice, [this](QVariantMap device) {
		mSettingsModelConnection->invokeToModel([this, device]() {
			mAutoSaved = true;
			SettingsModel::getInstance()->setCaptureDevice(device);
		});
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureDeviceChanged, [this](QVariantMap device) {
		mSettingsModelConnection->invokeToCore([this, device]() { setCaptureDevice(device); });
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetPlaybackDevice, [this](QVariantMap device) {
		mSettingsModelConnection->invokeToModel([this, device]() {
			mAutoSaved = true;
			SettingsModel::getInstance()->setPlaybackDevice(device);
		});
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackDeviceChanged, [this](QVariantMap device) {
		mSettingsModelConnection->invokeToCore([this, device]() { setPlaybackDevice(device); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ringerDeviceChanged, [this](QVariantMap device) {
		mSettingsModelConnection->invokeToCore([this, device]() { setRingerDevice(device); });
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetPlaybackGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel([this, value]() {
			mAutoSaved = true;
			SettingsModel::getInstance()->setPlaybackGain(value);
		});
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackGainChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() { setPlaybackGainFromModel(value); });
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetCaptureGain, [this](const float value) {
		mSettingsModelConnection->invokeToModel([this, value]() {
			mAutoSaved = true;
			SettingsModel::getInstance()->setCaptureGain(value);
		});
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureGainChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() { setCaptureGainFromModel(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::micVolumeChanged, [this](const float value) {
		mSettingsModelConnection->invokeToCore([this, value]() { emit micVolumeChanged(value); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::captureDevicesChanged, [this](QVariantList devices) {
		mSettingsModelConnection->invokeToCore([this, devices]() { setCaptureDevices(devices); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::playbackDevicesChanged, [this](QVariantList devices) {
		mSettingsModelConnection->invokeToCore([this, devices]() { setPlaybackDevices(devices); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ringerDevicesChanged, [this](QVariantList devices) {
		mSettingsModelConnection->invokeToCore([this, devices]() { setRingerDevices(devices); });
	});

	// Video device(s)
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetVideoDevice, [this](QString id) {
		mSettingsModelConnection->invokeToModel([this, id]() {
			mAutoSaved = true;
			SettingsModel::getInstance()->setVideoDevice(id);
		});
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::ringtoneChanged, [this](QString ringtonePath) {
		mSettingsModelConnection->invokeToCore([this, ringtonePath]() { setRingtone(ringtonePath); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::videoDeviceChanged, [this](const QString device) {
		mSettingsModelConnection->invokeToCore([this, device]() { setVideoDevice(device); });
	});

	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lSetConferenceLayout, [this](QVariantMap layout) {
		auto linLayout = LinphoneEnums::toLinphone(LinphoneEnums::ConferenceLayout(layout["id"].toInt()));
		mSettingsModelConnection->invokeToModel([this, linLayout]() {
			mAutoSaved = true;
			SettingsModel::getInstance()->setDefaultConferenceLayout(linLayout);
		});
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::conferenceLayoutChanged, [this]() {
		auto layout = LinphoneEnums::fromLinphone(SettingsModel::getInstance()->getDefaultConferenceLayout());
		mSettingsModelConnection->invokeToCore(
		    [this, layout]() { setConferenceLayout(LinphoneEnums::toVariant(layout)); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::mediaEncryptionChanged, [this]() {
		auto encryption = LinphoneEnums::toVariant(
		    LinphoneEnums::fromLinphone(SettingsModel::getInstance()->getDefaultMediaEncryption()));
		mSettingsModelConnection->invokeToCore([this, encryption]() { setMediaEncryption(encryption); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::mediaEncryptionMandatoryChanged, [this]() {
		auto mandatory = SettingsModel::getInstance()->getMediaEncryptionMandatory();
		mSettingsModelConnection->invokeToCore([this, mandatory]() { setMediaEncryptionMandatory(mandatory); });
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::createEndToEndEncryptedMeetingsAndGroupCallsChanged,
	                                             [this](bool endtoend) {
		                                             mSettingsModelConnection->invokeToCore([this, endtoend]() {
			                                             setCreateEndToEndEncryptedMeetingsAndGroupCalls(endtoend);
		                                             });
	                                             });

	mSettingsModelConnection->makeConnectToModel(
	    &SettingsModel::videoDevicesChanged, [this](const QStringList devices) {
		    mSettingsModelConnection->invokeToCore([this, devices]() { setVideoDevices(devices); });
	    });

	// Logs
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::logsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() {
			setCrashReporterEnabled(status);
			setLogsEnabled(status);
		});
	});

	mSettingsModelConnection->makeConnectToModel(&SettingsModel::fullLogsEnabledChanged, [this](const bool status) {
		mSettingsModelConnection->invokeToCore([this, status]() { setFullLogsEnabled(status); });
	});

	// DND
	mSettingsModelConnection->makeConnectToCore(&SettingsCore::lEnableDnd, [this](const bool value) {
		mSettingsModelConnection->invokeToModel([this, value]() { SettingsModel::getInstance()->enableDnd(value); });
	});
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::dndChanged, [this](const bool value) {
		mSettingsModelConnection->invokeToCore([this, value]() { setDndEnabled(value); });
	});

	// CardDAV
	mSettingsModelConnection->makeConnectToModel(&SettingsModel::cardDAVMinCharResearchChanged, [this](int min) {
		mSettingsModelConnection->invokeToCore([this, min]() { setCardDAVMinCharForResearch(min); });
	});

	auto settingsModel = SettingsModel::getInstance();

	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableChatFeature, DisableChatFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableMeetingsFeature, DisableMeetingsFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableBroadcastFeature, DisableBroadcastFeature)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, hideSettings,
	                           HideSettings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           hideAccountSettings, HideAccountSettings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, hideFps,
	                           HideFps)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableCallRecordings, DisableCallRecordings)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantHideCreateAccount, AssistantHideCreateAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantDisableQrCode, AssistantDisableQrCode)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantHideThirdPartyAccount, AssistantHideThirdPartyAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           hideSipAddresses, HideSipAddresses)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           darkModeAllowed, DarkModeAllowed)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, int, maxAccount,
	                           MaxAccount)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           assistantGoDirectlyToThirdPartySipAccountLogin,
	                           AssistantGoDirectlyToThirdPartySipAccountLogin)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           assistantThirdPartySipAccountDomain, AssistantThirdPartySipAccountDomain)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           assistantThirdPartySipAccountTransport, AssistantThirdPartySipAccountTransport)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, autoStart,
	                           AutoStart)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool, exitOnClose,
	                           ExitOnClose)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           syncLdapContacts, SyncLdapContacts)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           configLocale, ConfigLocale)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           downloadFolder, DownloadFolder)
	DEFINE_CORE_GET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, int, shortcutCount,
	                        ShortcutCount)
	DEFINE_CORE_GET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QVariantList,
	                        shortcuts, Shortcuts)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           callToneIndicationsEnabled, CallToneIndicationsEnabled)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           commandLine, CommandLine)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, bool,
	                           disableCommandLine, DisableCommandLine)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           themeAboutPictureUrl, ThemeAboutPictureUrl)
	DEFINE_CORE_GETSET_CONNECT(mSettingsModelConnection, SettingsCore, SettingsModel, settingsModel, QString,
	                           themeMainColor, ThemeMainColor)

	auto coreModelConnection = SafeConnection<SettingsCore, CoreModel>::create(me, CoreModel::getInstance());

	coreModelConnection->makeConnectToModel(
	    &CoreModel::logCollectionUploadStateChanged, [this](auto core, auto state, auto info) {
		    mSettingsModelConnection->invokeToCore([this, state, info]() {
			    if (state == linphone::Core::LogCollectionUploadState::Delivered ||
			        state == linphone::Core::LogCollectionUploadState::NotDelivered) {
				    emit logsUploadTerminated(state == linphone::Core::LogCollectionUploadState::Delivered,
				                              Utils::coreStringToAppString(info));
			    }
		    });
	    });
	coreModelConnection->makeConnectToModel(
	    &CoreModel::defaultAccountChanged,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account) {
		    QString accountDomain;
		    if (account) {
			    accountDomain = Utils::coreStringToAppString(account->getParams()->getDomain());
		    }
		    mSettingsModelConnection->invokeToCore(
		        [this, accountDomain]() { setShowAccountDevices(accountDomain == mDefaultDomain); });
	    });
}

void SettingsCore::reset(const SettingsCore &settingsCore) {
	// Security
	setVfsEnabled(settingsCore.mVfsEnabled);

	// Call
	setVideoEnabled(settingsCore.mVideoEnabled);
	setEchoCancellationEnabled(settingsCore.mEchoCancellationEnabled);
	setAutomaticallyRecordCallsEnabled(settingsCore.mAutomaticallyRecordCallsEnabled);

	setAutoDownloadReceivedFiles(settingsCore.mAutoDownloadReceivedFiles);
	setDisplayNotificationContent(settingsCore.mDisplayNotificationContent);
	// Audio
	setCaptureDevices(settingsCore.mCaptureDevices);
	setPlaybackDevices(settingsCore.mPlaybackDevices);
	setRingerDevices(settingsCore.mRingerDevices);
	setCaptureDevice(settingsCore.mCaptureDevice);
	setPlaybackDevice(settingsCore.mPlaybackDevice);

	setConferenceLayouts(settingsCore.mConferenceLayouts);
	setConferenceLayout(settingsCore.mConferenceLayout);

	setMediaEncryptions(settingsCore.mMediaEncryptions);
	setMediaEncryption(settingsCore.mMediaEncryption);

	setMediaEncryptionMandatory(settingsCore.mMediaEncryptionMandatory);
	setCreateEndToEndEncryptedMeetingsAndGroupCalls(settingsCore.mCreateEndToEndEncryptedMeetingsAndGroupCalls);

	setCaptureGain(settingsCore.mCaptureGain);
	setPlaybackGain(settingsCore.mPlaybackGain);

	// Video
	setVideoDevice(settingsCore.mVideoDevice);
	setVideoDevices(settingsCore.mVideoDevices);

	// Logs
	setLogsEnabled(settingsCore.mLogsEnabled);
	setFullLogsEnabled(settingsCore.mFullLogsEnabled);
	setCrashReporterEnabled(settingsCore.mCrashReporterEnabled);
	setLogsFolder(settingsCore.mLogsFolder);

	// DND
	setDndEnabled(settingsCore.mDndEnabled);

	// UI
	setDisableChatFeature(settingsCore.mDisableChatFeature);
	setDisableMeetingsFeature(settingsCore.mDisableMeetingsFeature);
	setDisableBroadcastFeature(settingsCore.mDisableBroadcastFeature);
	setHideSettings(settingsCore.mHideSettings);
	setHideAccountSettings(settingsCore.mHideAccountSettings);
	setHideFps(settingsCore.mHideFps);
	setDisableCallRecordings(settingsCore.mDisableCallRecordings);
	setAssistantHideCreateAccount(settingsCore.mAssistantHideCreateAccount);
	setAssistantHideCreateAccount(settingsCore.mAssistantHideCreateAccount);
	setAssistantDisableQrCode(settingsCore.mAssistantDisableQrCode);

	setAssistantHideThirdPartyAccount(settingsCore.mAssistantHideThirdPartyAccount);
	setHideSipAddresses(settingsCore.mHideSipAddresses);
	setDarkModeAllowed(settingsCore.mDarkModeAllowed);
	setMaxAccount(settingsCore.mMaxAccount);
	setAssistantGoDirectlyToThirdPartySipAccountLogin(settingsCore.mAssistantGoDirectlyToThirdPartySipAccountLogin);
	setAssistantThirdPartySipAccountDomain(settingsCore.mAssistantThirdPartySipAccountDomain);
	setAssistantThirdPartySipAccountTransport(settingsCore.mAssistantThirdPartySipAccountTransport);
	setExitOnClose(settingsCore.mExitOnClose);
	setSyncLdapContacts(settingsCore.mSyncLdapContacts);
	setCardDAVMinCharForResearch(settingsCore.mCardDAVMinCharForResearch);
	setIpv6Enabled(settingsCore.mIpv6Enabled);
	setAutoStart(settingsCore.mAutoStart);
	setConfigLocale(settingsCore.mConfigLocale);
	setDownloadFolder(settingsCore.mDownloadFolder);
	setCallForwardToAddress(settingsCore.mCallForwardToAddress);
}

QString SettingsCore::getConfigPath(const QCommandLineParser &parser) {
	QString filePath = parser.isSet("config") ? parser.value("config") : "";
	QString configPath;
	if (!QUrl(filePath).isRelative()) {
		// configPath = FileDownloader::synchronousDownload(filePath,
		// Utils::coreStringToAppString(Paths::getConfigDirPath(false)), true));
	}
	if (configPath == "") configPath = Paths::getConfigFilePath(filePath, false);
	if (configPath == "" && !filePath.isEmpty()) configPath = Paths::getConfigFilePath("", false);
	return configPath;
}

void SettingsCore::setVfsEnabled(bool enabled) {
	if (mVfsEnabled != enabled) {
		mVfsEnabled = enabled;
		emit vfsEnabledChanged();
		setIsSaved(false);
	}
}

bool SettingsCore::getVfsEncrypted() {
	mAppSettings.beginGroup("keychain");
	return mAppSettings.value("enabled", false).toBool();
}

void SettingsCore::setVfsEncrypted(bool encrypted, const bool deleteUserData) {
#ifdef ENABLE_QT_KEYCHAIN
	if (getVfsEncrypted() != encrypted) {
		if (encrypted) {
			mVfsUtils.newEncryptionKeyAsync();
			shared_ptr<linphone::Factory> factory = linphone::Factory::get();
			factory->setDownloadDir(Utils::appStringToCoreString(getDownloadFolder()));
		} else { // Remove key, stop core, delete data and initiate reboot
			mVfsUtils.needToDeleteUserData(deleteUserData);
			mVfsUtils.deleteKey(mVfsUtils.getApplicationVfsEncryptionKey());
		}
	}
#endif
}

void SettingsCore::setVideoEnabled(bool enabled) {
	if (mVideoEnabled != enabled) {
		mVideoEnabled = enabled;
		emit videoEnabledChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setEchoCancellationEnabled(bool enabled) {
	if (mEchoCancellationEnabled != enabled) {
		mEchoCancellationEnabled = enabled;
		emit echoCancellationEnabledChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setIpv6Enabled(bool enabled) {
	if (mIpv6Enabled != enabled) {
		mIpv6Enabled = enabled;
		emit ipv6EnabledChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setAutoStart(bool enabled) {
	if (mAutoStart != enabled) {
		mAutoStart = enabled;
		setIsSaved(false);
	}
}

void SettingsCore::setCallForwardToAddress(QString address) {
	if (mCallForwardToAddress != address) {
		mCallForwardToAddress = address;
		setIsSaved(false);
	}
}

void SettingsCore::setHideFps(bool hide) {
	if (mHideFps != hide) {
		mHideFps = hide;
		emit hideFpsChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setAutoDownloadReceivedFiles(bool enabled) {
	if (mAutoDownloadReceivedFiles != enabled) {
		mAutoDownloadReceivedFiles = enabled;
		emit autoDownloadReceivedFilesChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setDisplayNotificationContent(bool enabled) {
	if (mDisplayNotificationContent != enabled) {
		mDisplayNotificationContent = enabled;
		emit displayNotificationContentChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setAutomaticallyRecordCallsEnabled(bool enabled) {
	if (mAutomaticallyRecordCallsEnabled != enabled) {
		mAutomaticallyRecordCallsEnabled = enabled;
		emit automaticallyRecordCallsEnabledChanged();
		setIsSaved(false);
	}
}

QVariantList SettingsCore::getCaptureDevices() const {
	return mCaptureDevices;
}

void SettingsCore::setCaptureDevices(QVariantList devices) {
	mCaptureDevices = devices;
	emit captureDevicesChanged(devices);
}

QVariantList SettingsCore::getPlaybackDevices() const {
	return mPlaybackDevices;
}

void SettingsCore::setPlaybackDevices(QVariantList devices) {
	mPlaybackDevices = devices;
	emit playbackDevicesChanged(devices);
}

QVariantList SettingsCore::getRingerDevices() const {
	return mRingerDevices;
}

void SettingsCore::setRingerDevices(QVariantList devices) {
	mRingerDevices = devices;
	emit captureDevicesChanged(devices);
}

QVariantList SettingsCore::getConferenceLayouts() const {
	return mConferenceLayouts;
}

void SettingsCore::setConferenceLayouts(QVariantList layouts) {
	mConferenceLayouts = layouts;
	emit conferenceLayoutsChanged(layouts);
}

QVariantList SettingsCore::getMediaEncryptions() const {
	return mMediaEncryptions;
}

void SettingsCore::setMediaEncryptions(QVariantList encryptions) {
	mMediaEncryptions = encryptions;
	emit mediaEncryptionsChanged(encryptions);
}

bool SettingsCore::isMediaEncryptionMandatory() const {
	return mMediaEncryptionMandatory;
}

void SettingsCore::setMediaEncryptionMandatory(bool mandatory) {
	if (mMediaEncryptionMandatory != mandatory) {
		mMediaEncryptionMandatory = mandatory;
		emit mediaEncryptionMandatoryChanged(mandatory);
		setIsSaved(false);
	}
}

bool SettingsCore::getCreateEndToEndEncryptedMeetingsAndGroupCalls() const {
	return mCreateEndToEndEncryptedMeetingsAndGroupCalls;
}

void SettingsCore::setCreateEndToEndEncryptedMeetingsAndGroupCalls(bool endtoend) {
	if (mCreateEndToEndEncryptedMeetingsAndGroupCalls != endtoend) {
		mCreateEndToEndEncryptedMeetingsAndGroupCalls = endtoend;
		emit createEndToEndEncryptedMeetingsAndGroupCallsChanged(endtoend);
		setIsSaved(false);
	}
}

bool SettingsCore::isSaved() const {
	return mIsSaved;
}

void SettingsCore::setIsSaved(bool saved) {
	if (mIsSaved != saved) {
		mIsSaved = saved;
		emit isSavedChanged(saved);
	}
}

void SettingsCore::setVideoDevice(QString device) {
	if (mVideoDevice != device) {
		mVideoDevice = device;
		emit videoDeviceChanged();
		if (mAutoSaved) {
			mAutoSaved = false;
		} else {
			setIsSaved(false);
		}
	}
}

void SettingsCore::setVideoDevices(QStringList devices) {
	if (mVideoDevices != devices) {
		mVideoDevices = devices;
		emit videoDevicesChanged();
	}
}

int SettingsCore::getVideoDeviceIndex() const {
	return mVideoDevices.indexOf(mVideoDevice);
}

QStringList SettingsCore::getVideoDevices() const {
	return mVideoDevices;
}

bool SettingsCore::getCaptureGraphRunning() {
	return mCaptureGraphRunning;
}

float SettingsCore::getCaptureGain() const {
	return mCaptureGain;
}

void SettingsCore::setCaptureGain(float gain) {
	if (mCaptureGain != gain) {
		mCaptureGain = gain;
		emit captureGainChanged(gain);
		if (mAutoSaved) {
			mAutoSaved = false;
		} else {
			setIsSaved(false);
		}
	}
}

void SettingsCore::setCaptureGainFromModel(float gain) {
	if (mCaptureGain != gain) {
		mCaptureGain = gain;
		emit captureGainChanged(gain);
	}
}

QVariantMap SettingsCore::getConferenceLayout() const {
	return mConferenceLayout;
}

void SettingsCore::setConferenceLayout(QVariantMap layout) {
	if (mConferenceLayout["id"] != layout["id"]) {
		mConferenceLayout = layout;
		emit conferenceLayoutChanged();
		if (mAutoSaved) {
			mAutoSaved = false;
		} else {
			setIsSaved(false);
		}
	}
}

QVariantMap SettingsCore::getMediaEncryption() const {
	return mMediaEncryption;
}

void SettingsCore::setMediaEncryption(QVariantMap encryption) {
	if (mMediaEncryption != encryption) {
		mMediaEncryption = encryption;
		emit mediaEncryptionChanged();
		setIsSaved(false);
	}
}

float SettingsCore::getPlaybackGain() const {
	return mPlaybackGain;
}

void SettingsCore::setPlaybackGain(float gain) {
	if (mPlaybackGain != gain) {
		mPlaybackGain = gain;
		emit playbackGainChanged(gain);
		if (mAutoSaved) {
			mAutoSaved = false;
		} else {
			setIsSaved(false);
		}
	}
}

void SettingsCore::setPlaybackGainFromModel(float gain) {
	if (mPlaybackGain != gain) {
		mPlaybackGain = gain;
		emit playbackGainChanged(gain);
	}
}

QVariantMap SettingsCore::getCaptureDevice() const {
	return mCaptureDevice;
}

void SettingsCore::setCaptureDevice(QVariantMap device) {
	if (mCaptureDevice["id"] != device["id"]) {
		mCaptureDevice = device;
		emit captureDeviceChanged(device);
		if (mAutoSaved) {
			mAutoSaved = false;
		} else {
			setIsSaved(false);
		}
	}
}

QVariantMap SettingsCore::getPlaybackDevice() const {
	return mPlaybackDevice;
}

void SettingsCore::setPlaybackDevice(QVariantMap device) {
	if (mPlaybackDevice["id"] != device["id"]) {
		mPlaybackDevice = device;
		emit playbackDeviceChanged(device);
		if (mAutoSaved) {
			mAutoSaved = false;
		} else {
			setIsSaved(false);
		}
	}
}

QVariantMap SettingsCore::getRingerDevice() const {
	return mRingerDevice;
}

void SettingsCore::setRingerDevice(QVariantMap device) {
	if (mRingerDevice["id"] != device["id"]) {
		mRingerDevice = device;
		emit ringerDeviceChanged(mRingerDevice);
		setIsSaved(false);
	}
}

int SettingsCore::getEchoCancellationCalibration() const {
	return mEchoCancellationCalibration;
}

bool SettingsCore::getFirstLaunch() const {
	auto val = mAppSettings.value("firstLaunch", 1).toInt();
	return val;
}

void SettingsCore::setFirstLaunch(bool first) {
	auto firstLaunch = getFirstLaunch();
	if (firstLaunch != first) {
		mAppSettings.setValue("firstLaunch", (int)first);
		mAppSettings.sync();
		emit firstLaunchChanged(first);
	}
}

void SettingsCore::setLastActiveTabIndex(int index) {
	auto lastActiveIndex = getLastActiveTabIndex();
	if (lastActiveIndex != index) {
		mAppSettings.setValue("lastActiveTabIndex", index);
		mAppSettings.sync();
		emit lastActiveTabIndexChanged();
	}
}

int SettingsCore::getLastActiveTabIndex() {
	return mAppSettings.value("lastActiveTabIndex", 1).toInt();
}

void SettingsCore::setDisplayDeviceCheckConfirmation(bool display) {
	if (getDisplayDeviceCheckConfirmation() != display) {
		mAppSettings.setValue("displayDeviceCheckConfirmation", display);
		mAppSettings.sync();
		emit showVerifyDeviceConfirmationChanged(display);
	}
}

bool SettingsCore::getDisplayDeviceCheckConfirmation() const {
	auto val = mAppSettings.value("displayDeviceCheckConfirmation", 1).toInt();
	return val;
}

void SettingsCore::startEchoCancellerCalibration() {
	mSettingsModelConnection->invokeToModel(
	    [this]() { SettingsModel::getInstance()->startEchoCancellerCalibration(); });
}

void SettingsCore::accessCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->accessCallSettings(); });
}
void SettingsCore::closeCallSettings() {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->closeCallSettings(); });
}

void SettingsCore::updateMicVolume() const {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->getMicVolume(); });
}

bool SettingsCore::getLogsEnabled() const {
	return mLogsEnabled;
}

void SettingsCore::setLogsEnabled(bool enabled) {
	if (mLogsEnabled != enabled) {
		mLogsEnabled = enabled;
		emit logsEnabledChanged();
		setIsSaved(false);
	}
}

bool SettingsCore::getFullLogsEnabled() const {
	return mFullLogsEnabled;
}

void SettingsCore::setFullLogsEnabled(bool enabled) {
	if (mFullLogsEnabled != enabled) {
		mFullLogsEnabled = enabled;
		emit fullLogsEnabledChanged();
		setIsSaved(false);
	}
}

bool SettingsCore::getCrashReporterEnabled() const {
	return mCrashReporterEnabled;
}

void SettingsCore::setCrashReporterEnabled(bool enabled) {
	if (mCrashReporterEnabled != enabled) {
		mCrashReporterEnabled = enabled;
		emit crashReporterEnabledChanged();
		setIsSaved(false);
	}
}

void SettingsCore::setRingtone(QString path) {
	if (mRingtonePath != path) {
		mRingtonePath = path;
		QFileInfo ringtone(path);
		if (ringtone.exists()) {
			mRingtoneFileName = ringtone.fileName();
			mRingtoneFolder = ringtone.absolutePath();
		} else {
			mRingtoneFileName = mRingtonePath.right(mRingtonePath.lastIndexOf(QDir::separator()));
			mRingtoneFolder = mRingtonePath.left(mRingtonePath.lastIndexOf(QDir::separator()));
		}
		emit ringtoneChanged();
		setIsSaved(false);
	}
}

QString SettingsCore::getRingtoneFileName() const {
	return mRingtoneFileName;
}

QString SettingsCore::getRingtonePath() const {
	return mRingtonePath;
}

void SettingsCore::cleanLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->cleanLogs(); });
}

void SettingsCore::sendLogs() const {
	mSettingsModelConnection->invokeToModel([this]() { SettingsModel::getInstance()->sendLogs(); });
}

QString SettingsCore::getLogsEmail() const {
	return mLogsEmail;
}

QString SettingsCore::getLogsFolder() const {
	return mLogsFolder;
}

void SettingsCore::setLogsFolder(QString folder) {
	if (mLogsFolder != folder) {
		mLogsFolder = folder;
		emit logsFolderChanged(folder);
		setIsSaved(false);
	}
}

bool SettingsCore::dndEnabled() const {
	return mDndEnabled;
}

void SettingsCore::setDndEnabled(bool enabled) {
	if (mDndEnabled != enabled) {
		mDndEnabled = enabled;
		emit dndChanged();
	}
}

bool SettingsCore::showAccountDevices() const {
	return mShowAccountDevices;
}
void SettingsCore::setShowAccountDevices(bool show) {
	if (mShowAccountDevices != show) {
		mShowAccountDevices = show;
		emit showAccountDevicesChanged(mShowAccountDevices);
	}
}

bool SettingsCore::getExitOnClose() const {
	return mExitOnClose;
}

bool SettingsCore::getSyncLdapContacts() const {
	return mSyncLdapContacts;
}

bool SettingsCore::getCardDAVMinCharForResearch() const {
	return mCardDAVMinCharForResearch;
}

void SettingsCore::setCardDAVMinCharForResearch(int min) {
	if (mCardDAVMinCharForResearch != min) {
		mCardDAVMinCharForResearch = min;
		emit cardDAVMinCharForResearchChanged(mCardDAVMinCharForResearch);
	}
}

QString SettingsCore::getConfigLocale() const {
	return mConfigLocale;
}

QString SettingsCore::getDownloadFolder() const {
	auto path = mDownloadFolder;
	if (mDownloadFolder.isEmpty()) path = Paths::getDownloadDirPath();
	QString cleanPath = QDir::cleanPath(path);
	if (!cleanPath.endsWith(QDir::separator())) cleanPath.append(QDir::separator());
	return cleanPath;
}

void SettingsCore::setDownloadFolder(QString folder) {
	if (mDownloadFolder != folder) {
		mDownloadFolder = folder;
		emit downloadFolderChanged();
		setIsSaved(false);
	}
}

void SettingsCore::writeIntoModel(std::shared_ptr<SettingsModel> model) const {
	mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
	// Security
	model->setVfsEnabled(mVfsEnabled);

	// Call
	model->setVideoEnabled(mVideoEnabled);
	model->setEchoCancellationEnabled(mEchoCancellationEnabled);
	model->setAutomaticallyRecordCallsEnabled(mAutomaticallyRecordCallsEnabled);

	// Chat
	model->setAutoDownloadReceivedFiles(mAutoDownloadReceivedFiles);

	model->setDisplayNotificationContent(mDisplayNotificationContent);

	// Audio
	model->setRingerDevice(mRingerDevice);
	model->setCaptureDevice(mCaptureDevice);
	model->setPlaybackDevice(mPlaybackDevice);
	model->setRingtone(mRingtonePath);

	model->setDefaultConferenceLayout(
	    LinphoneEnums::toLinphone(LinphoneEnums::ConferenceLayout(mConferenceLayout["id"].toInt())));

	model->setDefaultMediaEncryption(
	    LinphoneEnums::toLinphone(LinphoneEnums::MediaEncryption(mMediaEncryption["id"].toInt())));

	model->setMediaEncryptionMandatory(mMediaEncryptionMandatory);
	model->setCreateEndToEndEncryptedMeetingsAndGroupCalls(mCreateEndToEndEncryptedMeetingsAndGroupCalls);

	model->setCaptureGain(mCaptureGain);
	model->setPlaybackGain(mPlaybackGain);

	// Video
	model->setVideoDevice(mVideoDevice);

	// Logs
	model->setLogsEnabled(mLogsEnabled);
	model->setFullLogsEnabled(mFullLogsEnabled);
	model->setCrashReporterEnabled(mLogsEnabled);

	// UI
	model->setDisableChatFeature(mDisableChatFeature);
	model->setDisableMeetingsFeature(mDisableMeetingsFeature);
	model->setDisableBroadcastFeature(mDisableBroadcastFeature);
	model->setHideSettings(mHideSettings);
	model->setHideAccountSettings(mHideAccountSettings);
	model->setHideFps(mHideFps);
	model->setDisableCallRecordings(mDisableCallRecordings);
	model->setAssistantHideCreateAccount(mAssistantHideCreateAccount);
	model->setAssistantHideCreateAccount(mAssistantHideCreateAccount);
	model->setAssistantDisableQrCode(mAssistantDisableQrCode);

	model->setAssistantHideThirdPartyAccount(mAssistantHideThirdPartyAccount);
	model->setHideSipAddresses(mHideSipAddresses);
	model->setDarkModeAllowed(mDarkModeAllowed);
	model->setMaxAccount(mMaxAccount);
	model->setAssistantGoDirectlyToThirdPartySipAccountLogin(mAssistantGoDirectlyToThirdPartySipAccountLogin);
	model->setAssistantThirdPartySipAccountDomain(mAssistantThirdPartySipAccountDomain);
	model->setAssistantThirdPartySipAccountTransport(mAssistantThirdPartySipAccountTransport);
	model->setExitOnClose(mExitOnClose);
	model->setSyncLdapContacts(mSyncLdapContacts);
	model->setIpv6Enabled(mIpv6Enabled);
	model->setAutoStart(mAutoStart);
	model->setConfigLocale(mConfigLocale);
	model->setDownloadFolder(mDownloadFolder);
	model->setCallForwardToAddress(mCallForwardToAddress);
}

void SettingsCore::writeFromModel(const std::shared_ptr<SettingsModel> &model) {
	mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);

	// Security
	mVfsEnabled = model->getVfsEnabled();

	// Call
	mVideoEnabled = model->getVideoEnabled();
	mEchoCancellationEnabled = model->getEchoCancellationEnabled();
	mAutomaticallyRecordCallsEnabled = model->getAutomaticallyRecordCallsEnabled();
	mRingtonePath = model->getRingtone();
	QFileInfo ringtone(mRingtonePath);
	mRingtoneFolder = ringtone.exists() ? ringtone.absolutePath() : "";
	mRingtoneFileName =
	    ringtone.exists() ? ringtone.fileName() : mRingtonePath.right(mRingtonePath.lastIndexOf(QDir::separator()));

	// Advanced
	mAutoStart = model->getAutoStart();

	// Chat
	mAutoDownloadReceivedFiles = model->getAutoDownloadReceivedFiles();
	mDisplayNotificationContent = model->getDisplayNotificationContent();

	// Audio
	mCaptureDevices = model->getCaptureDevices();
	mPlaybackDevices = model->getPlaybackDevices();
	mRingerDevices = model->getRingerDevices();
	mRingerDevice = model->getRingerDevice();
	mCaptureDevice = model->getCaptureDevice();
	mPlaybackDevice = model->getPlaybackDevice();

	mConferenceLayout = LinphoneEnums::toVariant(LinphoneEnums::fromLinphone(model->getDefaultConferenceLayout()));

	mMediaEncryption = LinphoneEnums::toVariant(LinphoneEnums::fromLinphone(model->getDefaultMediaEncryption()));

	mMediaEncryptionMandatory = model->getMediaEncryptionMandatory();
	mCreateEndToEndEncryptedMeetingsAndGroupCalls = model->getCreateEndToEndEncryptedMeetingsAndGroupCalls();

	mCaptureGain = model->getCaptureGain();
	mPlaybackGain = model->getPlaybackGain();

	// Video
	mVideoDevice = model->getVideoDevice();
	mVideoDevices = model->getVideoDevices();

	// Logs
	mLogsEnabled = model->getLogsEnabled();
	mFullLogsEnabled = model->getFullLogsEnabled();
	mCrashReporterEnabled = model->getCrashReporterEnabled();
	mLogsFolder = model->getLogsFolder();
	mLogsEmail = model->getLogsEmail();

	// Check update
	mIsCheckForUpdateAvailable = model->isCheckForUpdateAvailable();

	// UI
	mDisableChatFeature = model->getDisableChatFeature();
	mDisableMeetingsFeature = model->getDisableMeetingsFeature();
	mDisableBroadcastFeature = model->getDisableBroadcastFeature();
	mHideSettings = model->getHideSettings();
	mHideAccountSettings = model->getHideAccountSettings();
	mHideFps = model->getHideFps();
	mDisableCallRecordings = model->getDisableCallRecordings();
	mAssistantHideCreateAccount = model->getAssistantHideCreateAccount();
	mAssistantHideCreateAccount = model->getAssistantHideCreateAccount();
	mAssistantDisableQrCode = model->getAssistantDisableQrCode();

	mAssistantHideThirdPartyAccount = model->getAssistantHideThirdPartyAccount();
	mHideSipAddresses = model->getHideSipAddresses();
	mDarkModeAllowed = model->getDarkModeAllowed();
	mMaxAccount = model->getMaxAccount();
	mAssistantGoDirectlyToThirdPartySipAccountLogin = model->getAssistantGoDirectlyToThirdPartySipAccountLogin();
	mAssistantThirdPartySipAccountDomain = model->getAssistantThirdPartySipAccountDomain();
	mAssistantThirdPartySipAccountTransport = model->getAssistantThirdPartySipAccountTransport();
	mAutoStart = model->getAutoStart();
	mExitOnClose = model->getExitOnClose();
	mSyncLdapContacts = model->getSyncLdapContacts();
	mCardDAVMinCharForResearch = model->getCardDAVMinCharResearch();
	mIpv6Enabled = model->getIpv6Enabled();
	mAutoStart = model->getAutoStart();
	mConfigLocale = model->getConfigLocale();
	mDownloadFolder = model->getDownloadFolder();
	mCallForwardToAddress = model->getCallForwardToAddress();
}

bool SettingsCore::isCheckForUpdateAvailable() const {
	return mIsCheckForUpdateAvailable;
}

void SettingsCore::save() {
	mustBeInMainThread(getClassName() + Q_FUNC_INFO);
	SettingsCore *thisCopy = new SettingsCore(*this);
	emit autoStartChanged();
	if (SettingsModel::getInstance()) {
		mSettingsModelConnection->invokeToModel([this, thisCopy] {
			mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
			thisCopy->writeIntoModel(SettingsModel::getInstance());
			thisCopy->deleteLater();
			mSettingsModelConnection->invokeToCore([this]() { setIsSaved(true); });
		});
	}
}

void SettingsCore::undo() {
	if (SettingsModel::getInstance()) {
		mSettingsModelConnection->invokeToModel([this] {
			SettingsCore *settings = new SettingsCore(*this);
			settings->writeFromModel(SettingsModel::getInstance());
			settings->moveToThread(App::getInstance()->thread());
			mSettingsModelConnection->invokeToCore([this, settings]() {
				this->reset(*settings);
				settings->deleteLater();
			});
		});
	}
}
