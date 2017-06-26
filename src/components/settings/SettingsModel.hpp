/*
 * SettingsModel.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class SettingsModel : public QObject {
  Q_OBJECT;

  // ===========================================================================
  // PROPERTIES.
  // ===========================================================================

  // Audio. --------------------------------------------------------------------

  Q_PROPERTY(QStringList captureDevices READ getCaptureDevices CONSTANT);
  Q_PROPERTY(QStringList playbackDevices READ getPlaybackDevices CONSTANT);

  Q_PROPERTY(QString captureDevice READ getCaptureDevice WRITE setCaptureDevice NOTIFY captureDeviceChanged);
  Q_PROPERTY(QString playbackDevice READ getPlaybackDevice WRITE setPlaybackDevice NOTIFY playbackDeviceChanged);
  Q_PROPERTY(QString ringerDevice READ getRingerDevice WRITE setRingerDevice NOTIFY ringerDeviceChanged);

  Q_PROPERTY(QString ringPath READ getRingPath WRITE setRingPath NOTIFY ringPathChanged);

  Q_PROPERTY(bool echoCancellationEnabled READ getEchoCancellationEnabled WRITE setEchoCancellationEnabled NOTIFY echoCancellationEnabledChanged);

  // Video. --------------------------------------------------------------------

  Q_PROPERTY(QStringList videoDevices READ getVideoDevices CONSTANT);

  Q_PROPERTY(QString videoDevice READ getVideoDevice WRITE setVideoDevice NOTIFY videoDeviceChanged);

  Q_PROPERTY(QString videoPreset READ getVideoPreset WRITE setVideoPreset NOTIFY videoPresetChanged);
  Q_PROPERTY(int videoFramerate READ getVideoFramerate WRITE setVideoFramerate NOTIFY videoFramerateChanged);

  Q_PROPERTY(QVariantList supportedVideoDefinitions READ getSupportedVideoDefinitions CONSTANT);

  Q_PROPERTY(QVariantMap videoDefinition READ getVideoDefinition WRITE setVideoDefinition NOTIFY videoDefinitionChanged);

  // Chat & calls. -------------------------------------------------------------

  Q_PROPERTY(bool autoAnswerStatus READ getAutoAnswerStatus WRITE setAutoAnswerStatus NOTIFY autoAnswerStatusChanged);
  Q_PROPERTY(int autoAnswerDelay READ getAutoAnswerDelay WRITE setAutoAnswerDelay NOTIFY autoAnswerDelayChanged);

  Q_PROPERTY(QString fileTransferUrl READ getFileTransferUrl WRITE setFileTransferUrl NOTIFY fileTransferUrlChanged);

  Q_PROPERTY(bool limeIsSupported READ getLimeIsSupported CONSTANT);
  Q_PROPERTY(QVariantList supportedMediaEncryptions READ getSupportedMediaEncryptions CONSTANT);

  Q_PROPERTY(MediaEncryption mediaEncryption READ getMediaEncryption WRITE setMediaEncryption NOTIFY mediaEncryptionChanged);
  Q_PROPERTY(LimeState limeState READ getLimeState WRITE setLimeState NOTIFY limeStateChanged);

  // Network. ------------------------------------------------------------------

  Q_PROPERTY(bool useSipInfoForDtmfs READ getUseSipInfoForDtmfs WRITE setUseSipInfoForDtmfs NOTIFY dtmfsProtocolChanged);
  Q_PROPERTY(bool useRfc2833ForDtmfs READ getUseRfc2833ForDtmfs WRITE setUseRfc2833ForDtmfs NOTIFY dtmfsProtocolChanged);

  Q_PROPERTY(bool ipv6Enabled READ getIpv6Enabled WRITE setIpv6Enabled NOTIFY ipv6EnabledChanged);

  Q_PROPERTY(int downloadBandwidth READ getDownloadBandwidth WRITE setDownloadBandwidth NOTIFY downloadBandWidthChanged);
  Q_PROPERTY(int uploadBandwidth READ getUploadBandwidth WRITE setUploadBandwidth NOTIFY uploadBandWidthChanged);

  Q_PROPERTY(
    bool adaptiveRateControlEnabled
    READ getAdaptiveRateControlEnabled
    WRITE setAdaptiveRateControlEnabled
    NOTIFY adaptiveRateControlEnabledChanged
  );

  Q_PROPERTY(int tcpPort READ getTcpPort WRITE setTcpPort NOTIFY tcpPortChanged);
  Q_PROPERTY(int udpPort READ getUdpPort WRITE setUdpPort NOTIFY udpPortChanged);
  Q_PROPERTY(int tlsPort READ getTlsPort WRITE setTlsPort NOTIFY tlsPortChanged);

  Q_PROPERTY(QList<int> audioPortRange READ getAudioPortRange WRITE setAudioPortRange NOTIFY audioPortRangeChanged);
  Q_PROPERTY(QList<int> videoPortRange READ getVideoPortRange WRITE setVideoPortRange NOTIFY videoPortRangeChanged);

  Q_PROPERTY(bool iceEnabled READ getIceEnabled WRITE setIceEnabled NOTIFY iceEnabledChanged);
  Q_PROPERTY(bool turnEnabled READ getTurnEnabled WRITE setTurnEnabled NOTIFY turnEnabledChanged);

  Q_PROPERTY(QString stunServer READ getStunServer WRITE setStunServer NOTIFY stunServerChanged);

  Q_PROPERTY(QString turnUser READ getTurnUser WRITE setTurnUser NOTIFY turnUserChanged);
  Q_PROPERTY(QString turnPassword READ getTurnPassword WRITE setTurnPassword NOTIFY turnPasswordChanged);

  Q_PROPERTY(int dscpSip READ getDscpSip WRITE setDscpSip NOTIFY dscpSipChanged);
  Q_PROPERTY(int dscpAudio READ getDscpAudio WRITE setDscpAudio NOTIFY dscpAudioChanged);
  Q_PROPERTY(int dscpVideo READ getDscpVideo WRITE setDscpVideo NOTIFY dscpVideoChanged);

  // UI. -----------------------------------------------------------------------

  Q_PROPERTY(QString remoteProvisioning READ getRemoteProvisioning WRITE setRemoteProvisioning NOTIFY remoteProvisioningChanged);

  Q_PROPERTY(QString savedScreenshotsFolder READ getSavedScreenshotsFolder WRITE setSavedScreenshotsFolder NOTIFY savedScreenshotsFolderChanged);
  Q_PROPERTY(QString savedVideosFolder READ getSavedVideosFolder WRITE setSavedVideosFolder NOTIFY savedVideosFolderChanged);
  Q_PROPERTY(QString downloadFolder READ getDownloadFolder WRITE setDownloadFolder NOTIFY downloadFolderChanged);

  Q_PROPERTY(bool exitOnClose READ getExitOnClose WRITE setExitOnClose NOTIFY exitOnCloseChanged);

  // Advanced. -----------------------------------------------------------------

  Q_PROPERTY(QString logsFolder READ getLogsFolder WRITE setLogsFolder NOTIFY logsFolderChanged);
  Q_PROPERTY(QString logsUploadUrl READ getLogsUploadUrl WRITE setLogsUploadUrl NOTIFY logsUploadUrlChanged);
  Q_PROPERTY(bool logsEnabled READ getLogsEnabled WRITE setLogsEnabled NOTIFY logsEnabledChanged);
  Q_PROPERTY(QString logsEmail READ getLogsEmail WRITE setLogsEmail NOTIFY logsEmailChanged);

public:
  enum MediaEncryption {
    MediaEncryptionNone = linphone::MediaEncryptionNone,
    MediaEncryptionDtls = linphone::MediaEncryptionDTLS,
    MediaEncryptionSrtp = linphone::MediaEncryptionSRTP,
    MediaEncryptionZrtp = linphone::MediaEncryptionZRTP
  };

  Q_ENUM(MediaEncryption);

  enum LimeState {
    LimeStateDisabled = linphone::LimeStateDisabled,
    LimeStateMandatory = linphone::LimeStateMandatory,
    LimeStatePreferred = linphone::LimeStatePreferred
  };

  Q_ENUM(LimeState);

  SettingsModel (QObject *parent = Q_NULLPTR);

  // ===========================================================================
  // METHODS.
  // ===========================================================================

  // Audio. --------------------------------------------------------------------

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

  // Video. --------------------------------------------------------------------

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

  // Chat & calls. -------------------------------------------------------------

  bool getAutoAnswerStatus () const;
  void setAutoAnswerStatus (bool status);

  int getAutoAnswerDelay () const;
  void setAutoAnswerDelay (int delay);

  QString getFileTransferUrl () const;
  void setFileTransferUrl (const QString &url);

  bool getLimeIsSupported () const;
  QVariantList getSupportedMediaEncryptions () const;

  MediaEncryption getMediaEncryption () const;
  void setMediaEncryption (MediaEncryption encryption);

  LimeState getLimeState () const;
  void setLimeState (LimeState state);

  // Network. ------------------------------------------------------------------

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

  int getTlsPort () const;
  void setTlsPort (int port);

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

  // UI. -----------------------------------------------------------------------

  QString getSavedScreenshotsFolder () const;
  void setSavedScreenshotsFolder (const QString &folder);

  QString getSavedVideosFolder () const;
  void setSavedVideosFolder (const QString &folder);

  QString getDownloadFolder () const;
  void setDownloadFolder (const QString &folder);

  QString getRemoteProvisioning () const;
  void setRemoteProvisioning (const QString &remoteProvisioning);

  bool getExitOnClose () const;
  void setExitOnClose (bool value);

  // ---------------------------------------------------------------------------

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

  static const std::string UI_SECTION;

  // ===========================================================================
  // SIGNALS.
  // ===========================================================================

signals:
  // Audio. --------------------------------------------------------------------

  void captureDeviceChanged (const QString &device);
  void playbackDeviceChanged (const QString &device);
  void ringerDeviceChanged (const QString &device);

  void ringPathChanged (const QString &path);

  void echoCancellationEnabledChanged (bool status);

  // Video. --------------------------------------------------------------------

  void videoDeviceChanged (const QString &device);

  void videoPresetChanged (const QString &preset);
  void videoFramerateChanged (int framerate);

  void videoDefinitionChanged (const QVariantMap &definition);

  // Chat & calls. -------------------------------------------------------------

  void autoAnswerStatusChanged (bool status);
  void autoAnswerDelayChanged (int delay);

  void fileTransferUrlChanged (const QString &url);

  void mediaEncryptionChanged (MediaEncryption encryption);
  void limeStateChanged (LimeState state);

  // Network. ------------------------------------------------------------------

  void dtmfsProtocolChanged ();

  void ipv6EnabledChanged (bool status);

  void downloadBandWidthChanged (int bandwidth);
  void uploadBandWidthChanged (int bandwidth);

  bool adaptiveRateControlEnabledChanged (bool status);

  void tcpPortChanged (int port);
  void udpPortChanged (int port);
  void tlsPortChanged (int port);

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

  // UI. -----------------------------------------------------------------------

  void savedScreenshotsFolderChanged (const QString &folder);
  void savedVideosFolderChanged (const QString &folder);
  void downloadFolderChanged (const QString &folder);

  void remoteProvisioningChanged (const QString &remoteProvisioning);
  void remoteProvisioningNotChanged (const QString &remoteProvisioning);

  void exitOnCloseChanged (bool value);

  // Advanced. -----------------------------------------------------------------

  void logsFolderChanged (const QString &folder);
  void logsUploadUrlChanged (const QString &url);
  void logsEnabledChanged (bool status);
  void logsEmailChanged (const QString &email);

private:
  std::shared_ptr<linphone::Config> mConfig;
};

Q_DECLARE_METATYPE(std::shared_ptr<const linphone::VideoDefinition> );

#endif // SETTINGS_MODEL_H_
