/*
 * SettingsModel.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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

#include <QDir>

#include "app/logger/Logger.hpp"
#include "app/paths/Paths.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "SettingsModel.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char DefaultRlsUri[] = "sips:rls@sip.linphone.org";
  constexpr char DefaultLogsEmail[] = "linphone-desktop@belledonne-communications.com";
}

const string SettingsModel::UiSection("ui");

SettingsModel::SettingsModel (QObject *parent) : QObject(parent) {
  mConfig = CoreManager::getInstance()->getCore()->getConfig();
  configureRlsUri();
}

// =============================================================================
// Assistant.
// =============================================================================

  bool SettingsModel::getUseAppSipAccountEnabled () const {
    return !!mConfig->getInt(UiSection, "use_app_sip_account_enabled", 1);
  }

  void SettingsModel::setUseAppSipAccountEnabled (bool status) {
    mConfig->setInt(UiSection, "use_app_sip_account_enabled", status);
    emit useAppSipAccountEnabledChanged(status);
  }

  bool SettingsModel::getUseOtherSipAccountEnabled () const {
    return !!mConfig->getInt(UiSection, "use_other_sip_account_enabled", 1);
  }

  void SettingsModel::setUseOtherSipAccountEnabled (bool status) {
    mConfig->setInt(UiSection, "use_other_sip_account_enabled", status);
    emit useOtherSipAccountEnabledChanged(status);
  }

  bool SettingsModel::getCreateAppSipAccountEnabled () const {
    return !!mConfig->getInt(UiSection, "create_app_sip_account_enabled", 1);
  }

  void SettingsModel::setCreateAppSipAccountEnabled (bool status) {
    mConfig->setInt(UiSection, "create_app_sip_account_enabled", status);
    emit createAppSipAccountEnabledChanged(status);
  }

  bool SettingsModel::getFetchRemoteConfigurationEnabled () const {
    return !!mConfig->getInt(UiSection, "fetch_remote_configuration_enabled", 1);
  }

  void SettingsModel::setFetchRemoteConfigurationEnabled (bool status) {
    mConfig->setInt(UiSection, "fetch_remote_configuration_enabled", status);
    emit fetchRemoteConfigurationEnabledChanged(status);
  }

  // ---------------------------------------------------------------------------

  bool SettingsModel::getAssistantSupportsPhoneNumbers () const {
    return !!mConfig->getInt(UiSection, "assistant_supports_phone_numbers", 1);
  }

  void SettingsModel::setAssistantSupportsPhoneNumbers (bool status) {
    mConfig->setInt(UiSection, "assistant_supports_phone_numbers", status);
    emit assistantSupportsPhoneNumbersChanged(status);
  }

// =============================================================================
// Audio.
// =============================================================================

QStringList SettingsModel::getCaptureDevices () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QStringList list;

  for (const auto &device : core->getSoundDevicesList()) {
    if (core->soundDeviceCanCapture(device))
      list << Utils::coreStringToAppString(device);
  }

  return list;
}

QStringList SettingsModel::getPlaybackDevices () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QStringList list;

  for (const auto &device : core->getSoundDevicesList())
    if (core->soundDeviceCanPlayback(device))
      list << Utils::coreStringToAppString(device);

  return list;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getCaptureDevice () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getCaptureDevice()
  );
}

void SettingsModel::setCaptureDevice (const QString &device) {
  CoreManager::getInstance()->getCore()->setCaptureDevice(
    Utils::appStringToCoreString(device)
  );
  emit captureDeviceChanged(device);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getPlaybackDevice () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getPlaybackDevice()
  );
}

void SettingsModel::setPlaybackDevice (const QString &device) {
  CoreManager::getInstance()->getCore()->setPlaybackDevice(
    Utils::appStringToCoreString(device)
  );
  emit playbackDeviceChanged(device);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRingerDevice () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getRingerDevice()
  );
}

void SettingsModel::setRingerDevice (const QString &device) {
  CoreManager::getInstance()->getCore()->setRingerDevice(
    Utils::appStringToCoreString(device)
  );
  emit ringerDeviceChanged(device);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRingPath () const {
  return Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->getRing());
}

void SettingsModel::setRingPath (const QString &path) {
  QString cleanedPath = QDir::cleanPath(path);

  CoreManager::getInstance()->getCore()->setRing(
    Utils::appStringToCoreString(cleanedPath)
  );

  emit ringPathChanged(cleanedPath);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getEchoCancellationEnabled () const {
  return CoreManager::getInstance()->getCore()->echoCancellationEnabled();
}

void SettingsModel::setEchoCancellationEnabled (bool status) {
  CoreManager::getInstance()->getCore()->enableEchoCancellation(status);
  emit echoCancellationEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getShowAudioCodecs () const {
  return !!mConfig->getInt(UiSection, "show_audio_codecs", 1);
}

void SettingsModel::setShowAudioCodecs (bool status) {
  mConfig->setInt(UiSection, "show_audio_codecs", status);
  emit showAudioCodecsChanged(status);
}

// =============================================================================
// Video.
// =============================================================================

QStringList SettingsModel::getVideoDevices () const {
  QStringList list;

  for (const auto &device : CoreManager::getInstance()->getCore()->getVideoDevicesList())
    list << Utils::coreStringToAppString(device);

  return list;
}

// -----------------------------------------------------------------------------

QString SettingsModel::getVideoDevice () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getVideoDevice()
  );
}

void SettingsModel::setVideoDevice (const QString &device) {
  CoreManager::getInstance()->getCore()->setVideoDevice(
    Utils::appStringToCoreString(device)
  );
  emit videoDeviceChanged(device);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getVideoPreset () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getVideoPreset()
  );
}

void SettingsModel::setVideoPreset (const QString &preset) {
  CoreManager::getInstance()->getCore()->setVideoPreset(
    Utils::appStringToCoreString(preset)
  );
  emit videoPresetChanged(preset);
}

// -----------------------------------------------------------------------------

int SettingsModel::getVideoFramerate () const {
  return int(CoreManager::getInstance()->getCore()->getPreferredFramerate());
}

void SettingsModel::setVideoFramerate (int framerate) {
  CoreManager::getInstance()->getCore()->setPreferredFramerate(float(framerate));
  emit videoFramerateChanged(framerate);
}

// -----------------------------------------------------------------------------

static inline QVariantMap createMapFromVideoDefinition (const shared_ptr<const linphone::VideoDefinition> &definition) {
  QVariantMap map;

  if (!definition) {
    Q_ASSERT(!CoreManager::getInstance()->getCore()->videoSupported());

    map["name"] = QStringLiteral("Bad EGG");
    map["width"] = QStringLiteral("?????");
    map["height"] = QStringLiteral("?????");

    return map;
  }

  map["name"] = Utils::coreStringToAppString(definition->getName());
  map["width"] = definition->getWidth();
  map["height"] = definition->getHeight();
  map["__definition"] = QVariant::fromValue(definition);

  return map;
}

QVariantList SettingsModel::getSupportedVideoDefinitions () const {
  QVariantList list;
  for (const auto &definition : linphone::Factory::get()->getSupportedVideoDefinitions())
    list << createMapFromVideoDefinition(definition);
  return list;
}

QVariantMap SettingsModel::getVideoDefinition () const {
  return createMapFromVideoDefinition(CoreManager::getInstance()->getCore()->getPreferredVideoDefinition());
}

void SettingsModel::setVideoDefinition (const QVariantMap &definition) {
  CoreManager::getInstance()->getCore()->setPreferredVideoDefinition(
    definition.value("__definition").value<shared_ptr<const linphone::VideoDefinition>>()->clone()
  );

  emit videoDefinitionChanged(definition);
}

bool SettingsModel::getVideoSupported () const {
  return CoreManager::getInstance()->getCore()->videoSupported();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getShowVideoCodecs () const {
  return !!mConfig->getInt(UiSection, "show_video_codecs", 1);
}

void SettingsModel::setShowVideoCodecs (bool status) {
  mConfig->setInt(UiSection, "show_video_codecs", status);
  emit showVideoCodecsChanged(status);
}

// =============================================================================
// Chat & calls.
// =============================================================================

bool SettingsModel::getAutoAnswerStatus () const {
  return !!mConfig->getInt(UiSection, "auto_answer", 0);
}

void SettingsModel::setAutoAnswerStatus (bool status) {
  mConfig->setInt(UiSection, "auto_answer", status);
  emit autoAnswerStatusChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAutoAnswerVideoStatus () const {
  return !!mConfig->getInt(UiSection, "auto_answer_with_video", 0);
}

void SettingsModel::setAutoAnswerVideoStatus (bool status) {
  mConfig->setInt(UiSection, "auto_answer_with_video", status);
  emit autoAnswerVideoStatusChanged(status);
}

// -----------------------------------------------------------------------------

int SettingsModel::getAutoAnswerDelay () const {
  return mConfig->getInt(UiSection, "auto_answer_delay", 0);
}

void SettingsModel::setAutoAnswerDelay (int delay) {
  mConfig->setInt(UiSection, "auto_answer_delay", delay);
  emit autoAnswerDelayChanged(delay);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getShowTelKeypadAutomatically () const {
  return !!mConfig->getInt(UiSection, "show_tel_keypad_automatically", 0);
}

void SettingsModel::setShowTelKeypadAutomatically (bool status) {
  mConfig->setInt(UiSection, "show_tel_keypad_automatically", status);
  emit showTelKeypadAutomaticallyChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getKeepCallsWindowInBackground () const {
  return !!mConfig->getInt(UiSection, "keep_calls_window_in_background", 0);
}

void SettingsModel::setKeepCallsWindowInBackground (bool status) {
  mConfig->setInt(UiSection, "keep_calls_window_in_background", status);
  emit keepCallsWindowInBackgroundChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getOutgoingCallsEnabled () const {
  return !!mConfig->getInt(UiSection, "outgoing_calls_enabled", 1);
}

void SettingsModel::setOutgoingCallsEnabled (bool status) {
  mConfig->setInt(UiSection, "outgoing_calls_enabled", status);
  emit outgoingCallsEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getCallRecorderEnabled () const {
  return !!mConfig->getInt(UiSection, "call_recorder_enabled", 1);
}

void SettingsModel::setCallRecorderEnabled (bool status) {
  mConfig->setInt(UiSection, "call_recorder_enabled", status);
  emit callRecorderEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAutomaticallyRecordCalls () const {
  return !!mConfig->getInt(UiSection, "automatically_record_calls", 0);
}

void SettingsModel::setAutomaticallyRecordCalls (bool status) {
  mConfig->setInt(UiSection, "automatically_record_calls", status);
  emit automaticallyRecordCallsChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getCallPauseEnabled () const {
  return !!mConfig->getInt(UiSection, "call_pause_enabled", 1);
}

void SettingsModel::setCallPauseEnabled (bool status) {
  mConfig->setInt(UiSection, "call_pause_enabled", status);
  emit callPauseEnabledChanged(status);
}

bool SettingsModel::getMuteMicrophoneEnabled () const {
  return !!mConfig->getInt(UiSection, "mute_microphone_enabled", 1);
}

void SettingsModel::setMuteMicrophoneEnabled (bool status) {
  mConfig->setInt(UiSection, "mute_microphone_enabled", status);
  emit muteMicrophoneEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getChatEnabled () const {
  return !!mConfig->getInt(UiSection, "chat_enabled", 1);
}

void SettingsModel::setChatEnabled (bool status) {
  mConfig->setInt(UiSection, "chat_enabled", status);
  emit chatEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getConferenceEnabled () const {
  return !!mConfig->getInt(UiSection, "conference_enabled", 1);
}

void SettingsModel::setConferenceEnabled (bool status) {
  mConfig->setInt(UiSection, "conference_enabled", status);
  emit conferenceEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getChatNotificationSoundEnabled () const {
  return !!mConfig->getInt(UiSection, "chat_sound_notification_enabled", 1);
}

void SettingsModel::setChatNotificationSoundEnabled (bool status) {
  mConfig->setInt(UiSection, "chat_sound_notification_enabled", status);
  emit chatNotificationSoundEnabledChanged(status);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getChatNotificationSoundPath () const {
  static const string defaultFile = linphone::Factory::get()->getSoundResourcesDir() + "/incoming_chat.wav";
  return Utils::coreStringToAppString(mConfig->getString(UiSection, "chat_sound_notification_file", defaultFile));
}

void SettingsModel::setChatNotificationSoundPath (const QString &path) {
  QString cleanedPath = QDir::cleanPath(path);
  mConfig->setString(UiSection, "chat_sound_notification_file", Utils::appStringToCoreString(cleanedPath));
  emit chatNotificationSoundPathChanged(cleanedPath);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getFileTransferUrl () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getFileTransferServer()
  );
}

void SettingsModel::setFileTransferUrl (const QString &url) {
  CoreManager::getInstance()->getCore()->setFileTransferServer(
    Utils::appStringToCoreString(url)
  );
  emit fileTransferUrlChanged(url);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getLimeIsSupported () const {
  return CoreManager::getInstance()->getCore()->limeAvailable();
}

// -----------------------------------------------------------------------------

static inline QVariant buildEncryptionDescription (SettingsModel::MediaEncryption encryption, const char *description) {
  return QVariantList() << encryption << description;
}

QVariantList SettingsModel::getSupportedMediaEncryptions () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  QVariantList list;

  if (core->mediaEncryptionSupported(linphone::MediaEncryption::DTLS))
    list << buildEncryptionDescription(MediaEncryptionDtls, "DTLS");

  if (core->mediaEncryptionSupported(linphone::MediaEncryption::SRTP))
    list << buildEncryptionDescription(MediaEncryptionSrtp, "SRTP");

  if (core->mediaEncryptionSupported(linphone::MediaEncryption::ZRTP))
    list << buildEncryptionDescription(MediaEncryptionZrtp, "ZRTP");

  return list;
}

// -----------------------------------------------------------------------------

SettingsModel::MediaEncryption SettingsModel::getMediaEncryption () const {
  return static_cast<SettingsModel::MediaEncryption>(
    CoreManager::getInstance()->getCore()->getMediaEncryption()
  );
}

void SettingsModel::setMediaEncryption (MediaEncryption encryption) {
  if (encryption == getMediaEncryption())
    return;

  if (encryption != SettingsModel::MediaEncryptionZrtp)
    setLimeState(SettingsModel::LimeStateDisabled);

  CoreManager::getInstance()->getCore()->setMediaEncryption(
    static_cast<linphone::MediaEncryption>(encryption)
  );

  emit mediaEncryptionChanged(encryption);
}

// -----------------------------------------------------------------------------

SettingsModel::LimeState SettingsModel::getLimeState () const {
  return static_cast<SettingsModel::LimeState>(
    CoreManager::getInstance()->getCore()->limeEnabled()
  );
}

void SettingsModel::setLimeState (LimeState state) {
  if (state == getLimeState())
    return;

  if (state != SettingsModel::LimeStateDisabled)
    setMediaEncryption(SettingsModel::MediaEncryptionZrtp);

  CoreManager::getInstance()->getCore()->enableLime(
    static_cast<linphone::LimeState>(state)
  );

  emit limeStateChanged(state);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getContactsEnabled () const {
  return !!mConfig->getInt(UiSection, "contacts_enabled", 1);
}

void SettingsModel::setContactsEnabled (bool status) {
  mConfig->setInt(UiSection, "contacts_enabled", status);
  emit contactsEnabledChanged(status);
}

// =============================================================================
// Network.
// =============================================================================

bool SettingsModel::getShowNetworkSettings () const {
  return !!mConfig->getInt(UiSection, "show_network_settings", 1);
}

void SettingsModel::setShowNetworkSettings (bool status) {
  mConfig->setInt(UiSection, "show_network_settings", status);
  emit showNetworkSettingsChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getUseSipInfoForDtmfs () const {
  return CoreManager::getInstance()->getCore()->getUseInfoForDtmf();
}

void SettingsModel::setUseSipInfoForDtmfs (bool status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  if (status) {
    core->setUseRfc2833ForDtmf(false);
    core->setUseInfoForDtmf(true);
  } else {
    core->setUseInfoForDtmf(false);
    core->setUseRfc2833ForDtmf(true);
  }

  emit dtmfsProtocolChanged();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getUseRfc2833ForDtmfs () const {
  return CoreManager::getInstance()->getCore()->getUseRfc2833ForDtmf();
}

void SettingsModel::setUseRfc2833ForDtmfs (bool status) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  if (status) {
    core->setUseInfoForDtmf(false);
    core->setUseRfc2833ForDtmf(true);
  } else {
    core->setUseRfc2833ForDtmf(false);
    core->setUseInfoForDtmf(true);
  }

  emit dtmfsProtocolChanged();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getIpv6Enabled () const {
  return CoreManager::getInstance()->getCore()->ipv6Enabled();
}

void SettingsModel::setIpv6Enabled (bool status) {
  CoreManager::getInstance()->getCore()->enableIpv6(status);
  emit ipv6EnabledChanged(status);
}

// -----------------------------------------------------------------------------

int SettingsModel::getDownloadBandwidth () const {
  return CoreManager::getInstance()->getCore()->getDownloadBandwidth();
}

void SettingsModel::setDownloadBandwidth (int bandwidth) {
  CoreManager::getInstance()->getCore()->setDownloadBandwidth(bandwidth);
  emit downloadBandWidthChanged(getDownloadBandwidth());
}

// -----------------------------------------------------------------------------

int SettingsModel::getUploadBandwidth () const {
  return CoreManager::getInstance()->getCore()->getUploadBandwidth();
}

void SettingsModel::setUploadBandwidth (int bandwidth) {
  CoreManager::getInstance()->getCore()->setUploadBandwidth(bandwidth);
  emit uploadBandWidthChanged(getUploadBandwidth());
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAdaptiveRateControlEnabled () const {
  return CoreManager::getInstance()->getCore()->adaptiveRateControlEnabled();
}

void SettingsModel::setAdaptiveRateControlEnabled (bool status) {
  CoreManager::getInstance()->getCore()->enableAdaptiveRateControl(status);
  emit adaptiveRateControlEnabledChanged(status);
}

// -----------------------------------------------------------------------------

int SettingsModel::getTcpPort () const {
  return CoreManager::getInstance()->getCore()->getTransports()->getTcpPort();
}

void SettingsModel::setTcpPort (int port) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Transports> transports = core->getTransports();

  transports->setTcpPort(port);
  core->setTransports(transports);

  emit tcpPortChanged(port);
}

// -----------------------------------------------------------------------------

int SettingsModel::getUdpPort () const {
  return CoreManager::getInstance()->getCore()->getTransports()->getUdpPort();
}

void SettingsModel::setUdpPort (int port) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::Transports> transports = core->getTransports();

  transports->setUdpPort(port);
  core->setTransports(transports);

  emit udpPortChanged(port);
}

// -----------------------------------------------------------------------------

QList<int> SettingsModel::getAudioPortRange () const {
  shared_ptr<linphone::Range> range = CoreManager::getInstance()->getCore()->getAudioPortsRange();
  return QList<int>() << range->getMin() << range->getMax();
}

void SettingsModel::setAudioPortRange (const QList<int> &range) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  int a = range[0];
  int b = range[1];

  if (b == -1)
    core->setAudioPort(a);
  else
    core->setAudioPortRange(a, b);

  emit audioPortRangeChanged(a, b);
}

// -----------------------------------------------------------------------------

QList<int> SettingsModel::getVideoPortRange () const {
  shared_ptr<linphone::Range> range = CoreManager::getInstance()->getCore()->getVideoPortsRange();
  return QList<int>() << range->getMin() << range->getMax();
}

void SettingsModel::setVideoPortRange (const QList<int> &range) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  int a = range[0];
  int b = range[1];

  if (b == -1)
    core->setVideoPort(a);
  else
    core->setVideoPortRange(a, b);

  emit videoPortRangeChanged(a, b);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getIceEnabled () const {
  return CoreManager::getInstance()->getCore()->getNatPolicy()->iceEnabled();
}

void SettingsModel::setIceEnabled (bool status) {
  shared_ptr<linphone::NatPolicy> natPolicy = CoreManager::getInstance()->getCore()->getNatPolicy();

  natPolicy->enableIce(status);
  natPolicy->enableStun(status);

  emit iceEnabledChanged(status);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getTurnEnabled () const {
  return CoreManager::getInstance()->getCore()->getNatPolicy()->turnEnabled();
}

void SettingsModel::setTurnEnabled (bool status) {
  CoreManager::getInstance()->getCore()->getNatPolicy()->enableTurn(status);
  emit turnEnabledChanged(status);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getStunServer () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getNatPolicy()->getStunServer()
  );
}

void SettingsModel::setStunServer (const QString &stunServer) {
  CoreManager::getInstance()->getCore()->getNatPolicy()->setStunServer(
    Utils::appStringToCoreString(stunServer)
  );
}

// -----------------------------------------------------------------------------

QString SettingsModel::getTurnUser () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getNatPolicy()->getStunServerUsername()
  );
}

void SettingsModel::setTurnUser (const QString &user) {
  CoreManager::getInstance()->getCore()->getNatPolicy()->setStunServerUsername(
    Utils::appStringToCoreString(user)
  );

  emit turnUserChanged(user);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getTurnPassword () const {
  shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());
  shared_ptr<linphone::NatPolicy> natPolicy(core->getNatPolicy());
  shared_ptr<const linphone::AuthInfo> authInfo(core->findAuthInfo(
    "",
    natPolicy->getStunServerUsername(),
    natPolicy->getStunServer()
  ));
  return authInfo ? Utils::coreStringToAppString(authInfo->getPassword()) : QString("");
}

void SettingsModel::setTurnPassword (const QString &password) {
  shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());
  shared_ptr<linphone::NatPolicy> natPolicy(core->getNatPolicy());

  const string &turnUser(natPolicy->getStunServerUsername());
  shared_ptr<const linphone::AuthInfo> authInfo(core->findAuthInfo("", turnUser, natPolicy->getStunServer()));
  if (authInfo) {
    shared_ptr<linphone::AuthInfo> clonedAuthInfo(authInfo->clone());
    clonedAuthInfo->setPassword(Utils::appStringToCoreString(password));

    core->addAuthInfo(clonedAuthInfo);
    core->removeAuthInfo(authInfo);
  } else
    core->addAuthInfo(linphone::Factory::get()->createAuthInfo(
      turnUser,
      turnUser,
      Utils::appStringToCoreString(password),
      "",
      "",
      ""
    ));

  emit turnPasswordChanged(password);
}

// -----------------------------------------------------------------------------

int SettingsModel::getDscpSip () const {
  return CoreManager::getInstance()->getCore()->getSipDscp();
}

void SettingsModel::setDscpSip (int dscp) {
  CoreManager::getInstance()->getCore()->setSipDscp(dscp);
  emit dscpSipChanged(dscp);
}

int SettingsModel::getDscpAudio () const {
  return CoreManager::getInstance()->getCore()->getAudioDscp();
}

void SettingsModel::setDscpAudio (int dscp) {
  CoreManager::getInstance()->getCore()->setAudioDscp(dscp);
  emit dscpAudioChanged(dscp);
}

int SettingsModel::getDscpVideo () const {
  return CoreManager::getInstance()->getCore()->getVideoDscp();
}

void SettingsModel::setDscpVideo (int dscp) {
  CoreManager::getInstance()->getCore()->setVideoDscp(dscp);
  emit dscpVideoChanged(dscp);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getRlsUriEnabled () const {
  return !!mConfig->getInt(UiSection, "rls_uri_enabled", true);
}

void SettingsModel::setRlsUriEnabled (bool status) {
  mConfig->setInt(UiSection, "rls_uri_enabled", status);
  mConfig->setString("sip", "rls_uri", status ? DefaultRlsUri : "");
  emit rlsUriEnabledChanged(status);
}

static string getRlsUriDomain () {
  static string domain;
  if (!domain.empty())
    return domain;

  shared_ptr<linphone::Address> linphoneAddress = CoreManager::getInstance()->getCore()->createAddress(DefaultRlsUri);
  Q_CHECK_PTR(linphoneAddress);
  domain = linphoneAddress->getDomain();
  return domain;
}

void SettingsModel::configureRlsUri () {
  // Ensure rls uri is empty.
  if (!getRlsUriEnabled()) {
    mConfig->setString("sip", "rls_uri", "");
    return;
  }

  // Set rls uri if necessary.
  const string domain = getRlsUriDomain();
  for (const auto &proxyConfig : CoreManager::getInstance()->getCore()->getProxyConfigList())
    if (proxyConfig->getDomain() == domain) {
      mConfig->setString("sip", "rls_uri", DefaultRlsUri);
      return;
    }

  mConfig->setString("sip", "rls_uri", "");
}

void SettingsModel::configureRlsUri (const shared_ptr<const linphone::ProxyConfig> &proxyConfig) {
  if (!getRlsUriEnabled()) {
    mConfig->setString("sip", "rls_uri", "");
    return;
  }

  const string domain = getRlsUriDomain();
  if (proxyConfig->getDomain() == domain) {
    mConfig->setString("sip", "rls_uri", DefaultRlsUri);
    return;
  }

  mConfig->setString("sip", "rls_uri", "");
}

// =============================================================================
// UI.
// =============================================================================

QString SettingsModel::getSavedScreenshotsFolder () const {
  return QDir::cleanPath(
    Utils::coreStringToAppString(
      mConfig->getString(UiSection, "saved_screenshots_folder", Paths::getCapturesDirPath())
    )
  ) + QDir::separator();
}

void SettingsModel::setSavedScreenshotsFolder (const QString &folder) {
  QString cleanedFolder = QDir::cleanPath(folder) + QDir::separator();
  mConfig->setString(UiSection, "saved_screenshots_folder", Utils::appStringToCoreString(cleanedFolder));
  emit savedScreenshotsFolderChanged(cleanedFolder);
}

// -----------------------------------------------------------------------------

static inline string getLegacySavedCallsFolder (const shared_ptr<linphone::Config> &config) {
  return config->getString(SettingsModel::UiSection, "saved_videos_folder", Paths::getCapturesDirPath());
}

QString SettingsModel::getSavedCallsFolder () const {
  return QDir::cleanPath(
    Utils::coreStringToAppString(
      mConfig->getString(UiSection, "saved_calls_folder", getLegacySavedCallsFolder(mConfig))
    )
  ) + QDir::separator();
}

void SettingsModel::setSavedCallsFolder (const QString &folder) {
  QString cleanedFolder = QDir::cleanPath(folder) + QDir::separator();
  mConfig->setString(UiSection, "saved_calls_folder", Utils::appStringToCoreString(cleanedFolder));
  emit savedCallsFolderChanged(cleanedFolder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getDownloadFolder () const {
  return QDir::cleanPath(
    Utils::coreStringToAppString(
      mConfig->getString(UiSection, "download_folder", Paths::getDownloadDirPath())
    )
  ) + QDir::separator();
}

void SettingsModel::setDownloadFolder (const QString &folder) {
  QString cleanedFolder = QDir::cleanPath(folder) + QDir::separator();
  mConfig->setString(UiSection, "download_folder", Utils::appStringToCoreString(cleanedFolder));
  emit downloadFolderChanged(cleanedFolder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getRemoteProvisioning () const {
  return Utils::coreStringToAppString(CoreManager::getInstance()->getCore()->getProvisioningUri());
}

void SettingsModel::setRemoteProvisioning (const QString &remoteProvisioning) {
  if (!CoreManager::getInstance()->getCore()->setProvisioningUri(Utils::appStringToCoreString(remoteProvisioning)))
    emit remoteProvisioningChanged(remoteProvisioning);
  else
    emit remoteProvisioningNotChanged(remoteProvisioning);
}

// -----------------------------------------------------------------------------

bool SettingsModel::getExitOnClose () const {
  return !!mConfig->getInt(UiSection, "exit_on_close", 0);
}

void SettingsModel::setExitOnClose (bool value) {
  mConfig->setInt(UiSection, "exit_on_close", value);
  emit exitOnCloseChanged(value);
}

// =============================================================================
// Advanced.
// =============================================================================

QString SettingsModel::getLogsFolder () const {
  return getLogsFolder(mConfig);
}

void SettingsModel::setLogsFolder (const QString &folder) {
  // Do not update path in linphone core.
  // Just update the config file.
  mConfig->setString(UiSection, "logs_folder", Utils::appStringToCoreString(folder));

  emit logsFolderChanged(folder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getLogsUploadUrl () const {
  return Utils::coreStringToAppString(
    CoreManager::getInstance()->getCore()->getLogCollectionUploadServerUrl()
  );
}

void SettingsModel::setLogsUploadUrl (const QString &url) {
  CoreManager::getInstance()->getCore()->setLogCollectionUploadServerUrl(
    Utils::appStringToCoreString(url)
  );

  emit logsUploadUrlChanged(getLogsUploadUrl());
}

// -----------------------------------------------------------------------------

bool SettingsModel::getLogsEnabled () const {
  return getLogsEnabled(mConfig);
}

void SettingsModel::setLogsEnabled (bool status) {
  mConfig->setInt(UiSection, "logs_enabled", status);
  Logger::getInstance()->enable(status);
  emit logsEnabledChanged(status);
}

// ---------------------------------------------------------------------------

QString SettingsModel::getLogsEmail () const {
  return Utils::coreStringToAppString(
    mConfig->getString(UiSection, "logs_email", DefaultLogsEmail)
  );
}

void SettingsModel::setLogsEmail (const QString &email) {
  mConfig->setString(UiSection, "logs_email", Utils::appStringToCoreString(email));
  emit logsEmailChanged(email);
}

// ---------------------------------------------------------------------------

QString SettingsModel::getLogsFolder (const shared_ptr<linphone::Config> &config) {
  return Utils::coreStringToAppString(config
    ? config->getString(UiSection, "logs_folder", Paths::getLogsDirPath())
    : Paths::getLogsDirPath());
}

bool SettingsModel::getLogsEnabled (const shared_ptr<linphone::Config> &config) {
  return config ? config->getInt(UiSection, "logs_enabled", false) : false;
}

// ---------------------------------------------------------------------------

bool SettingsModel::getDeveloperSettingsEnabled () const {
  #ifdef DEBUG
    return !!mConfig->getInt(UiSection, "developer_settings", 0);
  #else
    return false;
  #endif // ifdef DEBUG
}

void SettingsModel::setDeveloperSettingsEnabled (bool status) {
  #ifdef DEBUG
    mConfig->setInt(UiSection, "developer_settings", status);
    emit developerSettingsEnabledChanged(status);
  #else
    qWarning() << QStringLiteral("Unable to change developer settings mode in release version.");
  #endif // ifdef DEBUG
}
