/*
 * SettingsModel.cpp
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

#include <QDir>

#include "../../app/Paths.hpp"
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include "SettingsModel.hpp"

using namespace std;

// =============================================================================

const string SettingsModel::UI_SECTION("ui");

SettingsModel::SettingsModel (QObject *parent) : QObject(parent) {
  m_config = CoreManager::getInstance()->getCore()->getConfig();
}

// =============================================================================
// Chat & calls.
// =============================================================================

SettingsModel::MediaEncryption SettingsModel::getMediaEncryption () const {
  return static_cast<SettingsModel::MediaEncryption>(
    CoreManager::getInstance()->getCore()->getMediaEncryption()
  );
}

void SettingsModel::setMediaEncryption (MediaEncryption encryption) {
  CoreManager::getInstance()->getCore()->setMediaEncryption(
    static_cast<linphone::MediaEncryption>(encryption)
  );
  emit mediaEncryptionChanged(encryption);
}

// =============================================================================
// Network.
// =============================================================================

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

// bool SettingsModel::getTcpPortEnabled () const {}

// void SettingsModel::setTcpPortEnabled (bool status) {
// emit tcpPortEnabledChanged(status);
// }

// -----------------------------------------------------------------------------

QList<int> SettingsModel::getAudioPortRange () const {
  int a, b;
  CoreManager::getInstance()->getCore()->getAudioPortRange(a, b);
  return QList<int>() << a << b;
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
  int a, b;
  CoreManager::getInstance()->getCore()->getVideoPortRange(a, b);
  return QList<int>() << a << b;
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
  shared_ptr<linphone::NatPolicy> nat_policy = CoreManager::getInstance()->getCore()->getNatPolicy();

  nat_policy->enableIce(status);
  nat_policy->enableStun(status);

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
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getNatPolicy()->getStunServer()
  );
}

void SettingsModel::setStunServer (const QString &stun_server) {
  CoreManager::getInstance()->getCore()->getNatPolicy()->setStunServer(
    ::Utils::qStringToLinphoneString(stun_server)
  );
}

// -----------------------------------------------------------------------------

QString SettingsModel::getTurnUser () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getNatPolicy()->getStunServerUsername()
  );
}

void SettingsModel::setTurnUser (const QString &user) {
  CoreManager::getInstance()->getCore()->getNatPolicy()->setStunServerUsername(
    ::Utils::qStringToLinphoneString(user)
  );

  emit turnUserChanged(user);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getTurnPassword () const {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::NatPolicy> nat_policy = core->getNatPolicy();
  shared_ptr<linphone::AuthInfo> auth_info = core->findAuthInfo(nat_policy->getStunServerUsername(), "", "");

  return auth_info ? ::Utils::linphoneStringToQString(auth_info->getPasswd()) : "";
}

void SettingsModel::setTurnPassword (const QString &password) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
  shared_ptr<linphone::NatPolicy> nat_policy = core->getNatPolicy();

  const string &username = nat_policy->getStunServerUsername();
  shared_ptr<linphone::AuthInfo> auth_info = core->findAuthInfo(username, "", "");

  if (auth_info) {
    shared_ptr<linphone::AuthInfo> _auth_info = auth_info->clone();
    core->removeAuthInfo(auth_info);
    _auth_info->setPasswd(::Utils::qStringToLinphoneString(password));
    core->addAuthInfo(_auth_info);
  } else {
    auth_info = linphone::Factory::get()->createAuthInfo(username, username, ::Utils::qStringToLinphoneString(password), "", "", "");
    core->addAuthInfo(auth_info);
  }

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

// =============================================================================
// Misc.
// =============================================================================

bool SettingsModel::getAutoAnswerStatus () const {
  return !!m_config->getInt(UI_SECTION, "auto_answer", 0);
}

void SettingsModel::setAutoAnswerStatus (bool status) {
  m_config->setInt(UI_SECTION, "auto_answer", status);
  emit autoAnswerStatusChanged(status);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getFileTransferUrl () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getFileTransferServer()
  );
}

void SettingsModel::setFileTransferUrl (const QString &url) {
  CoreManager::getInstance()->getCore()->setFileTransferServer(
    ::Utils::qStringToLinphoneString(url)
  );
  emit fileTransferUrlChanged(url);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getSavedScreenshotsFolder () const {
  return QDir::cleanPath(
    ::Utils::linphoneStringToQString(
      m_config->getString(UI_SECTION, "saved_screenshots_folder", Paths::getCapturesDirPath())
    )
  ) + QDir::separator();
}

void SettingsModel::setSavedScreenshotsFolder (const QString &folder) {
  QString _folder = QDir::cleanPath(folder) + QDir::separator();

  m_config->setString(UI_SECTION, "saved_screenshots_folder", ::Utils::qStringToLinphoneString(_folder));
  emit savedScreenshotsFolderChanged(_folder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getSavedVideosFolder () const {
  return QDir::cleanPath(
    ::Utils::linphoneStringToQString(
      m_config->getString(UI_SECTION, "saved_videos_folder", Paths::getCapturesDirPath())
    )
  ) + QDir::separator();
}

void SettingsModel::setSavedVideosFolder (const QString &folder) {
  QString _folder = QDir::cleanPath(folder) + QDir::separator();

  m_config->setString(UI_SECTION, "saved_videos_folder", ::Utils::qStringToLinphoneString(_folder));
  emit savedVideosFolderChanged(_folder);
}
