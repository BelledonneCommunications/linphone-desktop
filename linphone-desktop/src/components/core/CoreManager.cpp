/*
 * CoreManager.cpp
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

#include "../../utils.hpp"
#include "../../app/Paths.hpp"

#include "CoreManager.hpp"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QTimer>

using namespace std;

// =============================================================================

CoreManager *CoreManager::m_instance = nullptr;

CoreManager::CoreManager (QObject *parent, const QString &config_path) : QObject(parent), m_handlers(make_shared<CoreHandlers>()) {
  // TODO: activate migration when ready to switch to this new version
  // Paths::migrate();

  setResourcesPaths();

  m_core = linphone::Factory::get()->createCore(m_handlers, Paths::getConfigFilepath(config_path), "");

  m_core->setVideoDisplayFilter("MSOGL");
  m_core->usePreviewWindow(true);

  setDatabasesPaths();
  setOtherPaths();
}

void CoreManager::enableHandlers () {
  m_cbs_timer->start();
}

void CoreManager::init (QObject *parent, const QString &config_path) {
  if (m_instance)
    return;

  m_instance = new CoreManager(parent, config_path);

  m_instance->m_calls_list_model = new CallsListModel(m_instance);
  m_instance->m_contacts_list_model = new ContactsListModel(m_instance);
  m_instance->m_sip_addresses_model = new SipAddressesModel(m_instance);
  m_instance->m_settings_model = new SettingsModel(m_instance);

  QTimer *timer = m_instance->m_cbs_timer = new QTimer(m_instance);
  timer->setInterval(20);

  QObject::connect(
    timer, &QTimer::timeout, m_instance, []() {
      m_instance->lockVideoRender();
      m_instance->m_core->iterate();
      m_instance->unlockVideoRender();
    }
  );
}

// -----------------------------------------------------------------------------

VcardModel *CoreManager::createDetachedVcardModel () {
  return new VcardModel(linphone::Factory::get()->createVcard());
}

void CoreManager::forceRefreshRegisters () {
  qInfo() << QStringLiteral("Refresh registers.");
  m_instance->m_core->refreshRegisters();
}

// -----------------------------------------------------------------------------

void CoreManager::setDatabasesPaths () {
  m_core->setFriendsDatabasePath(Paths::getFriendsListFilepath());
  m_core->setCallLogsDatabasePath(Paths::getCallHistoryFilepath());
  m_core->setChatDatabasePath(Paths::getMessageHistoryFilepath());
}

void CoreManager::setOtherPaths () {
  m_core->setZrtpSecretsFile(Paths::getZrtpSecretsFilepath());
  m_core->setUserCertificatesPath(Paths::getUserCertificatesDirpath());
}

void CoreManager::setResourcesPaths () {
  QDir dir(QCoreApplication::applicationDirPath());
  if (dir.dirName() == "MacOS") {
    dir.cdUp();
    dir.cd("Resources");
    QDir mspluginsdir(dir);
    mspluginsdir.cd("lib/mediastreamer/plugins");
    QDir datadir(dir);
    datadir.cd("share");

    shared_ptr<linphone::Factory> factory = linphone::Factory::get();
    factory->setMspluginsDir(::Utils::qStringToLinphoneString(mspluginsdir.absolutePath()));
    factory->setTopResourcesDir(::Utils::qStringToLinphoneString(datadir.absolutePath()));
  }
}
