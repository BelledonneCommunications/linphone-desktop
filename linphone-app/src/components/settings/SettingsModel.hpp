/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#include <linphone++/linphone.hh>
#include <utils/MediastreamerUtils.hpp>
#include <QObject>
#include <QVariantMap>

#include "components/core/CoreHandlers.hpp"
#include "components/contacts/ContactsImporterModel.hpp"

// =============================================================================

class SettingsModel : public QObject {
    Q_OBJECT

	// ===========================================================================
	// PROPERTIES.
	// ===========================================================================

	// Assistant. ----------------------------------------------------------------

    Q_PROPERTY(bool createAppSipAccountEnabled READ getCreateAppSipAccountEnabled WRITE setCreateAppSipAccountEnabled NOTIFY createAppSipAccountEnabledChanged)
    Q_PROPERTY(bool fetchRemoteConfigurationEnabled READ getFetchRemoteConfigurationEnabled WRITE setFetchRemoteConfigurationEnabled NOTIFY fetchRemoteConfigurationEnabledChanged)
    Q_PROPERTY(bool useAppSipAccountEnabled READ getUseAppSipAccountEnabled WRITE setUseAppSipAccountEnabled NOTIFY useAppSipAccountEnabledChanged)
    Q_PROPERTY(bool useOtherSipAccountEnabled READ getUseOtherSipAccountEnabled WRITE setUseOtherSipAccountEnabled NOTIFY useOtherSipAccountEnabledChanged)

    Q_PROPERTY(bool assistantSupportsPhoneNumbers READ getAssistantSupportsPhoneNumbers WRITE setAssistantSupportsPhoneNumbers NOTIFY assistantSupportsPhoneNumbersChanged)

	// Audio. --------------------------------------------------------------------

    Q_PROPERTY(bool captureGraphRunning READ getCaptureGraphRunning NOTIFY captureGraphRunningChanged)

    Q_PROPERTY(QStringList captureDevices READ getCaptureDevices NOTIFY captureDevicesChanged)
    Q_PROPERTY(QStringList playbackDevices READ getPlaybackDevices NOTIFY playbackDevicesChanged)

    Q_PROPERTY(float playbackGain READ getPlaybackGain WRITE setPlaybackGain NOTIFY playbackGainChanged)
    Q_PROPERTY(float captureGain READ getCaptureGain WRITE setCaptureGain NOTIFY captureGainChanged)

    Q_PROPERTY(QString captureDevice READ getCaptureDevice WRITE setCaptureDevice NOTIFY captureDeviceChanged)
    Q_PROPERTY(QString playbackDevice READ getPlaybackDevice WRITE setPlaybackDevice NOTIFY playbackDeviceChanged)
    Q_PROPERTY(QString ringerDevice READ getRingerDevice WRITE setRingerDevice NOTIFY ringerDeviceChanged)

    Q_PROPERTY(QString ringPath READ getRingPath WRITE setRingPath NOTIFY ringPathChanged)

    Q_PROPERTY(bool echoCancellationEnabled READ getEchoCancellationEnabled WRITE setEchoCancellationEnabled NOTIFY echoCancellationEnabledChanged)

    Q_PROPERTY(bool showAudioCodecs READ getShowAudioCodecs WRITE setShowAudioCodecs NOTIFY showAudioCodecsChanged)

	// Video. --------------------------------------------------------------------

    Q_PROPERTY(QStringList videoDevices READ getVideoDevices NOTIFY videoDevicesChanged)

    Q_PROPERTY(QString videoDevice READ getVideoDevice WRITE setVideoDevice NOTIFY videoDeviceChanged)

    Q_PROPERTY(QString videoPreset READ getVideoPreset WRITE setVideoPreset NOTIFY videoPresetChanged)
    Q_PROPERTY(int videoFramerate READ getVideoFramerate WRITE setVideoFramerate NOTIFY videoFramerateChanged)

    Q_PROPERTY(QVariantList supportedVideoDefinitions READ getSupportedVideoDefinitions CONSTANT)

    Q_PROPERTY(QVariantMap videoDefinition READ getVideoDefinition WRITE setVideoDefinition NOTIFY videoDefinitionChanged)

    Q_PROPERTY(bool videoSupported READ getVideoSupported CONSTANT)

    Q_PROPERTY(bool showVideoCodecs READ getShowVideoCodecs WRITE setShowVideoCodecs NOTIFY showVideoCodecsChanged)

	// Chat & calls. -------------------------------------------------------------

    Q_PROPERTY(bool autoAnswerStatus READ getAutoAnswerStatus WRITE setAutoAnswerStatus NOTIFY autoAnswerStatusChanged)
    Q_PROPERTY(bool autoAnswerVideoStatus READ getAutoAnswerVideoStatus WRITE setAutoAnswerVideoStatus NOTIFY autoAnswerVideoStatusChanged)
    Q_PROPERTY(int autoAnswerDelay READ getAutoAnswerDelay WRITE setAutoAnswerDelay NOTIFY autoAnswerDelayChanged)

    Q_PROPERTY(bool showTelKeypadAutomatically READ getShowTelKeypadAutomatically WRITE setShowTelKeypadAutomatically NOTIFY showTelKeypadAutomaticallyChanged)

    Q_PROPERTY(bool keepCallsWindowInBackground READ getKeepCallsWindowInBackground WRITE setKeepCallsWindowInBackground NOTIFY keepCallsWindowInBackgroundChanged)

    Q_PROPERTY(bool outgoingCallsEnabled READ getOutgoingCallsEnabled WRITE setOutgoingCallsEnabled NOTIFY outgoingCallsEnabledChanged)

    Q_PROPERTY(bool callRecorderEnabled READ getCallRecorderEnabled WRITE setCallRecorderEnabled NOTIFY callRecorderEnabledChanged)
    Q_PROPERTY(bool automaticallyRecordCalls READ getAutomaticallyRecordCalls WRITE setAutomaticallyRecordCalls NOTIFY automaticallyRecordCallsChanged)

    Q_PROPERTY(bool callPauseEnabled READ getCallPauseEnabled WRITE setCallPauseEnabled NOTIFY callPauseEnabledChanged)
    Q_PROPERTY(bool muteMicrophoneEnabled READ getMuteMicrophoneEnabled WRITE setMuteMicrophoneEnabled NOTIFY muteMicrophoneEnabledChanged)

    Q_PROPERTY(bool chatEnabled READ getChatEnabled WRITE setChatEnabled NOTIFY chatEnabledChanged)

    Q_PROPERTY(bool conferenceEnabled READ getConferenceEnabled WRITE setConferenceEnabled NOTIFY conferenceEnabledChanged)

    Q_PROPERTY(bool chatNotificationSoundEnabled READ getChatNotificationSoundEnabled WRITE setChatNotificationSoundEnabled NOTIFY chatNotificationSoundEnabledChanged)
    Q_PROPERTY(QString chatNotificationSoundPath READ getChatNotificationSoundPath WRITE setChatNotificationSoundPath NOTIFY chatNotificationSoundPathChanged)

    Q_PROPERTY(QString fileTransferUrl READ getFileTransferUrl WRITE setFileTransferUrl NOTIFY fileTransferUrlChanged)

    Q_PROPERTY(bool limeIsSupported READ getLimeIsSupported CONSTANT)
    Q_PROPERTY(QVariantList supportedMediaEncryptions READ getSupportedMediaEncryptions CONSTANT)

    Q_PROPERTY(MediaEncryption mediaEncryption READ getMediaEncryption WRITE setMediaEncryption NOTIFY mediaEncryptionChanged)
    Q_PROPERTY(bool mediaEncryptionMandatory READ mandatoryMediaEncryptionEnabled WRITE enableMandatoryMediaEncryption NOTIFY mediaEncryptionChanged)

    Q_PROPERTY(bool limeState READ getLimeState WRITE setLimeState NOTIFY limeStateChanged)

    Q_PROPERTY(bool contactsEnabled READ getContactsEnabled WRITE setContactsEnabled NOTIFY contactsEnabledChanged)

	// Network. ------------------------------------------------------------------

    Q_PROPERTY(bool showNetworkSettings READ getShowNetworkSettings WRITE setShowNetworkSettings NOTIFY showNetworkSettingsChanged)

    Q_PROPERTY(bool useSipInfoForDtmfs READ getUseSipInfoForDtmfs WRITE setUseSipInfoForDtmfs NOTIFY dtmfsProtocolChanged)
    Q_PROPERTY(bool useRfc2833ForDtmfs READ getUseRfc2833ForDtmfs WRITE setUseRfc2833ForDtmfs NOTIFY dtmfsProtocolChanged)

    Q_PROPERTY(bool ipv6Enabled READ getIpv6Enabled WRITE setIpv6Enabled NOTIFY ipv6EnabledChanged)

    Q_PROPERTY(int downloadBandwidth READ getDownloadBandwidth WRITE setDownloadBandwidth NOTIFY downloadBandWidthChanged)
    Q_PROPERTY(int uploadBandwidth READ getUploadBandwidth WRITE setUploadBandwidth NOTIFY uploadBandWidthChanged)

	Q_PROPERTY(
		   bool adaptiveRateControlEnabled
		   READ getAdaptiveRateControlEnabled
		   WRITE setAdaptiveRateControlEnabled
		   NOTIFY adaptiveRateControlEnabledChanged
           )

    Q_PROPERTY(int tcpPort READ getTcpPort WRITE setTcpPort NOTIFY tcpPortChanged)
    Q_PROPERTY(int udpPort READ getUdpPort WRITE setUdpPort NOTIFY udpPortChanged)

    Q_PROPERTY(QList<int> audioPortRange READ getAudioPortRange WRITE setAudioPortRange NOTIFY audioPortRangeChanged)
    Q_PROPERTY(QList<int> videoPortRange READ getVideoPortRange WRITE setVideoPortRange NOTIFY videoPortRangeChanged)

    Q_PROPERTY(bool iceEnabled READ getIceEnabled WRITE setIceEnabled NOTIFY iceEnabledChanged)
    Q_PROPERTY(bool turnEnabled READ getTurnEnabled WRITE setTurnEnabled NOTIFY turnEnabledChanged)

    Q_PROPERTY(QString stunServer READ getStunServer WRITE setStunServer NOTIFY stunServerChanged)

    Q_PROPERTY(QString turnUser READ getTurnUser WRITE setTurnUser NOTIFY turnUserChanged)
    Q_PROPERTY(QString turnPassword READ getTurnPassword WRITE setTurnPassword NOTIFY turnPasswordChanged)

    Q_PROPERTY(int dscpSip READ getDscpSip WRITE setDscpSip NOTIFY dscpSipChanged)
    Q_PROPERTY(int dscpAudio READ getDscpAudio WRITE setDscpAudio NOTIFY dscpAudioChanged)
    Q_PROPERTY(int dscpVideo READ getDscpVideo WRITE setDscpVideo NOTIFY dscpVideoChanged)

    Q_PROPERTY(bool rlsUriEnabled READ getRlsUriEnabled WRITE setRlsUriEnabled NOTIFY rlsUriEnabledChanged)

	// UI. -----------------------------------------------------------------------

    Q_PROPERTY(QString remoteProvisioning READ getRemoteProvisioning WRITE setRemoteProvisioning NOTIFY remoteProvisioningChanged)

    Q_PROPERTY(QString savedScreenshotsFolder READ getSavedScreenshotsFolder WRITE setSavedScreenshotsFolder NOTIFY savedScreenshotsFolderChanged)
    Q_PROPERTY(QString savedCallsFolder READ getSavedCallsFolder WRITE setSavedCallsFolder NOTIFY savedCallsFolderChanged)
    Q_PROPERTY(QString downloadFolder READ getDownloadFolder WRITE setDownloadFolder NOTIFY downloadFolderChanged)

    Q_PROPERTY(bool exitOnClose READ getExitOnClose WRITE setExitOnClose NOTIFY exitOnCloseChanged)

	Q_PROPERTY(bool showLocalSipAccount READ getShowLocalSipAccount CONSTANT)
	Q_PROPERTY(bool showStartChat READ getShowStartChatButton CONSTANT)
	Q_PROPERTY(bool showStartVideoCallButton READ getShowStartVideoCallButton CONSTANT)

	// Advanced. -----------------------------------------------------------------

    Q_PROPERTY(QString logsFolder READ getLogsFolder WRITE setLogsFolder NOTIFY logsFolderChanged)
    Q_PROPERTY(QString logsUploadUrl READ getLogsUploadUrl WRITE setLogsUploadUrl NOTIFY logsUploadUrlChanged)
    Q_PROPERTY(bool logsEnabled READ getLogsEnabled WRITE setLogsEnabled NOTIFY logsEnabledChanged)
    Q_PROPERTY(QString logsEmail READ getLogsEmail WRITE setLogsEmail NOTIFY logsEmailChanged)

    Q_PROPERTY(bool developerSettingsEnabled READ getDeveloperSettingsEnabled WRITE setDeveloperSettingsEnabled NOTIFY developerSettingsEnabledChanged)

    Q_PROPERTY(bool isInCall READ getIsInCall NOTIFY isInCallChanged)

public:
	enum MediaEncryption {
			      MediaEncryptionNone = int(linphone::MediaEncryption::None),
			      MediaEncryptionDtls = int(linphone::MediaEncryption::DTLS),
			      MediaEncryptionSrtp = int(linphone::MediaEncryption::SRTP),
			      MediaEncryptionZrtp = int(linphone::MediaEncryption::ZRTP)
	};
    Q_ENUM(MediaEncryption)


	SettingsModel (QObject *parent = Q_NULLPTR);
    virtual ~SettingsModel ();

	// ===========================================================================
	// METHODS.
	// ===========================================================================

	Q_INVOKABLE void onSettingsTabChanged(int idx);
	Q_INVOKABLE void settingsWindowClosing(void);

	// Assistant. ----------------------------------------------------------------

	bool getCreateAppSipAccountEnabled () const;
	void setCreateAppSipAccountEnabled (bool status);

	bool getFetchRemoteConfigurationEnabled () const;
	void setFetchRemoteConfigurationEnabled (bool status);

	bool getUseAppSipAccountEnabled () const;
	void setUseAppSipAccountEnabled (bool status);

	bool getUseOtherSipAccountEnabled () const;
	void setUseOtherSipAccountEnabled (bool status);

	bool getAssistantSupportsPhoneNumbers () const;
	void setAssistantSupportsPhoneNumbers (bool status);

	// Audio. --------------------------------------------------------------------

	void createCaptureGraph();
	bool getCaptureGraphRunning();
	void accessAudioSettings();
	void closeAudioSettings();

	Q_INVOKABLE float getMicVolume();

	float getPlaybackGain() const;
	void setPlaybackGain(float gain);

	float getCaptureGain() const;
	void setCaptureGain(float gain);

	QStringList getCaptureDevices () const;
	QStringList getPlaybackDevices () const;

	QString getCaptureDevice () const;
	void setCaptureDevice (const QString &device);

	QString getPlaybackDevice () const;
	void setPlaybackDevice (const QString &device);

	QString getRingerDevice () const;
	void setRingerDevice (const QString &device);

	QString getRingPath () const;
	void setRingPath (const QString &path);

	bool getEchoCancellationEnabled () const;
	void setEchoCancellationEnabled (bool status);

	Q_INVOKABLE void startEchoCancellerCalibration();

	bool getShowAudioCodecs () const;
	void setShowAudioCodecs (bool status);

	// Video. --------------------------------------------------------------------

	//Called from qml when accessing audio settings panel
	Q_INVOKABLE void accessVideoSettings();

	QStringList getVideoDevices () const;

	QString getVideoDevice () const;
	void setVideoDevice (const QString &device);

	QString getVideoPreset () const;
	void setVideoPreset (const QString &preset);

	int getVideoFramerate () const;
	void setVideoFramerate (int framerate);

	QVariantList getSupportedVideoDefinitions () const;

	QVariantMap getVideoDefinition () const;
	void setVideoDefinition (const QVariantMap &definition);

	bool getVideoSupported () const;

	bool getShowVideoCodecs () const;
	void setShowVideoCodecs (bool status);

	// Chat & calls. -------------------------------------------------------------

	bool getAutoAnswerStatus () const;
	void setAutoAnswerStatus (bool status);

	bool getAutoAnswerVideoStatus () const;
	void setAutoAnswerVideoStatus (bool status);

	int getAutoAnswerDelay () const;
	void setAutoAnswerDelay (int delay);

	bool getShowTelKeypadAutomatically () const;
	void setShowTelKeypadAutomatically (bool status);

	bool getKeepCallsWindowInBackground () const;
	void setKeepCallsWindowInBackground (bool status);

	bool getOutgoingCallsEnabled () const;
	void setOutgoingCallsEnabled (bool status);

	bool getCallRecorderEnabled () const;
	void setCallRecorderEnabled (bool status);

	bool getAutomaticallyRecordCalls () const;
	void setAutomaticallyRecordCalls (bool status);

	bool getCallPauseEnabled () const;
	void setCallPauseEnabled (bool status);

	bool getMuteMicrophoneEnabled () const;
	void setMuteMicrophoneEnabled (bool status);

	bool getChatEnabled () const;
	void setChatEnabled (bool status);

	bool getConferenceEnabled () const;
	void setConferenceEnabled (bool status);

	bool getChatNotificationSoundEnabled () const;
	void setChatNotificationSoundEnabled (bool status);

	QString getChatNotificationSoundPath () const;
	void setChatNotificationSoundPath (const QString &path);

	QString getFileTransferUrl () const;
	void setFileTransferUrl (const QString &url);

	bool getLimeIsSupported () const;
	QVariantList getSupportedMediaEncryptions () const;

	MediaEncryption getMediaEncryption () const;
	void setMediaEncryption (MediaEncryption encryption);

	bool mandatoryMediaEncryptionEnabled () const;
	void enableMandatoryMediaEncryption(bool mandatory);

	bool getLimeState () const;
	void setLimeState (const bool& state);

	bool getContactsEnabled () const;
	void setContactsEnabled (bool status);

	// Network. ------------------------------------------------------------------

	bool getShowNetworkSettings () const;
	void setShowNetworkSettings (bool status);

	bool getUseSipInfoForDtmfs () const;
	void setUseSipInfoForDtmfs (bool status);

	bool getUseRfc2833ForDtmfs () const;
	void setUseRfc2833ForDtmfs (bool status);

	bool getIpv6Enabled () const;
	void setIpv6Enabled (bool status);

	int getDownloadBandwidth () const;
	void setDownloadBandwidth (int bandwidth);

	int getUploadBandwidth () const;
	void setUploadBandwidth (int bandwidth);

	bool getAdaptiveRateControlEnabled () const;
	void setAdaptiveRateControlEnabled (bool status);

	int getTcpPort () const;
	void setTcpPort (int port);

	int getUdpPort () const;
	void setUdpPort (int port);

	QList<int> getAudioPortRange () const;
	void setAudioPortRange (const QList<int> &range);

	QList<int> getVideoPortRange () const;
	void setVideoPortRange (const QList<int> &range);

	bool getIceEnabled () const;
	void setIceEnabled (bool status);

	bool getTurnEnabled () const;
	void setTurnEnabled (bool status);

	QString getStunServer () const;
	void setStunServer (const QString &stunServer);

	QString getTurnUser () const;
	void setTurnUser (const QString &user);

	QString getTurnPassword () const;
	void setTurnPassword (const QString &password);

	int getDscpSip () const;
	void setDscpSip (int dscp);

	int getDscpAudio () const;
	void setDscpAudio (int dscp);

	int getDscpVideo () const;
	void setDscpVideo (int dscp);

	bool getRlsUriEnabled () const;
	void setRlsUriEnabled (bool status);

	void configureRlsUri ();
	void configureRlsUri (const std::shared_ptr<const linphone::ProxyConfig> &proxyConfig);

	// UI. -----------------------------------------------------------------------

	QString getSavedScreenshotsFolder () const;
	void setSavedScreenshotsFolder (const QString &folder);

	QString getSavedCallsFolder () const;
	void setSavedCallsFolder (const QString &folder);

	QString getDownloadFolder () const;
	void setDownloadFolder (const QString &folder);

	QString getRemoteProvisioning () const;
	void setRemoteProvisioning (const QString &remoteProvisioning);

	bool getExitOnClose () const;
	void setExitOnClose (bool value);

	bool getShowLocalSipAccount () const;
	bool getShowStartChatButton () const;
	bool getShowStartVideoCallButton () const;

	// Advanced. ---------------------------------------------------------------------------
	
	
	void accessAdvancedSettings();

	QString getLogsFolder () const;
	void setLogsFolder (const QString &folder);

	QString getLogsUploadUrl () const;
	void setLogsUploadUrl (const QString &url);

	bool getLogsEnabled () const;
	void setLogsEnabled (bool status);

	QString getLogsEmail () const;
	void setLogsEmail (const QString &email);

	// ---------------------------------------------------------------------------

	static QString getLogsFolder (const std::shared_ptr<linphone::Config> &config);
	static bool getLogsEnabled (const std::shared_ptr<linphone::Config> &config);

	// ---------------------------------------------------------------------------

	bool getDeveloperSettingsEnabled () const;
	void setDeveloperSettingsEnabled (bool status);

	void handleCallCreated(const std::shared_ptr<linphone::Call> &call);
	void handleCallStateChanged(const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	void handleEcCalibrationResult(linphone::EcCalibratorStatus status, int delayMs);

	bool getIsInCall() const;

	static const std::string UiSection;
	static const std::string ContactsSection;

	// ===========================================================================
	// SIGNALS.
	// ===========================================================================

signals:
	// Assistant. ----------------------------------------------------------------

	void createAppSipAccountEnabledChanged (bool status);
	void fetchRemoteConfigurationEnabledChanged (bool status);
	void useAppSipAccountEnabledChanged (bool status);
	void useOtherSipAccountEnabledChanged (bool status);

	void assistantSupportsPhoneNumbersChanged (bool status);

	// Audio. --------------------------------------------------------------------

	void captureGraphRunningChanged(bool running);

	void playbackGainChanged(float gain);
	void captureGainChanged(float gain);

	void captureDevicesChanged (const QStringList &devices);
	void playbackDevicesChanged (const QStringList &devices);

	void captureDeviceChanged (const QString &device);
	void playbackDeviceChanged (const QString &device);
	void ringerDeviceChanged (const QString &device);

	void ringPathChanged (const QString &path);

	void echoCancellationEnabledChanged (bool status);
	void echoCancellationStatus(int status, int msDelay);

	void showAudioCodecsChanged (bool status);

	// Video. --------------------------------------------------------------------

	void videoDevicesChanged (const QStringList &devices);
	void videoDeviceChanged (const QString &device);

	void videoPresetChanged (const QString &preset);
	void videoFramerateChanged (int framerate);

	void videoDefinitionChanged (const QVariantMap &definition);

	void showVideoCodecsChanged (bool status);

	// Chat & calls. -------------------------------------------------------------

	void autoAnswerStatusChanged (bool status);
	void autoAnswerVideoStatusChanged (bool status);
	void autoAnswerDelayChanged (int delay);

	void showTelKeypadAutomaticallyChanged (bool status);

	void keepCallsWindowInBackgroundChanged (bool status);

	void outgoingCallsEnabledChanged (bool status);

	void callRecorderEnabledChanged (bool status);
	void automaticallyRecordCallsChanged (bool status);

	void callPauseEnabledChanged (bool status);
	void muteMicrophoneEnabledChanged (bool status);

	void chatEnabledChanged (bool status);

	void conferenceEnabledChanged (bool status);

	void chatNotificationSoundEnabledChanged (bool status);
	void chatNotificationSoundPathChanged (const QString &path);

	void fileTransferUrlChanged (const QString &url);

	void mediaEncryptionChanged (MediaEncryption encryption);
	void limeStateChanged (bool state);

	void contactsEnabledChanged (bool status);

	// Network. ------------------------------------------------------------------

	void showNetworkSettingsChanged (bool status);

	void dtmfsProtocolChanged ();

	void ipv6EnabledChanged (bool status);

	void downloadBandWidthChanged (int bandwidth);
	void uploadBandWidthChanged (int bandwidth);

	bool adaptiveRateControlEnabledChanged (bool status);

	void tcpPortChanged (int port);
	void udpPortChanged (int port);

	void audioPortRangeChanged (int a, int b);
	void videoPortRangeChanged (int a, int b);

	void iceEnabledChanged (bool status);
	void turnEnabledChanged (bool status);

	void stunServerChanged (const QString &server);

	void turnUserChanged (const QString &user);
	void turnPasswordChanged (const QString &password);

	void dscpSipChanged (int dscp);
	void dscpAudioChanged (int dscp);
	void dscpVideoChanged (int dscp);

	void rlsUriEnabledChanged (bool status);

	// UI. -----------------------------------------------------------------------

	void savedScreenshotsFolderChanged (const QString &folder);
	void savedCallsFolderChanged (const QString &folder);
	void downloadFolderChanged (const QString &folder);

	void remoteProvisioningChanged (const QString &remoteProvisioning);
	void remoteProvisioningNotChanged (const QString &remoteProvisioning);

	void exitOnCloseChanged (bool value);

	// Advanced. -----------------------------------------------------------------

	void logsFolderChanged (const QString &folder);
	void logsUploadUrlChanged (const QString &url);
	void logsEnabledChanged (bool status);
	void logsEmailChanged (const QString &email);
	
	void contactImporterChanged();

	bool developerSettingsEnabledChanged (bool status);

	bool isInCallChanged(bool);

private:
	int mCurrentSettingsTab = 0;
	MediastreamerUtils::SimpleCaptureGraph *mSimpleCaptureGraph = nullptr;

	std::shared_ptr<linphone::Config> mConfig;
};

Q_DECLARE_METATYPE(std::shared_ptr<const linphone::VideoDefinition>);

#endif // SETTINGS_MODEL_H_
