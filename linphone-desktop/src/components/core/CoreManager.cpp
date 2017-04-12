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

#include "../../app/paths/Paths.hpp"
#include "../../utils.hpp"

#include "CoreManager.hpp"

#include <QDebug>
#include <QDir>
#include <QtConcurrent>
#include <QTimer>

using namespace std;

// =============================================================================

CoreManager *CoreManager::m_instance = nullptr;

CoreManager::CoreManager (QObject *parent, const QString &config_path) : QObject(parent), m_handlers(make_shared<CoreHandlers>()) {
  m_promise_build = QtConcurrent::run(this, &CoreManager::createLinphoneCore, config_path);

  QObject::connect(
    &m_promise_watcher, &QFutureWatcher<void>::finished, this, []() {
      m_instance->m_calls_list_model = new CallsListModel(m_instance);
      m_instance->m_contacts_list_model = new ContactsListModel(m_instance);
      m_instance->m_sip_addresses_model = new SipAddressesModel(m_instance);
      m_instance->m_settings_model = new SettingsModel(m_instance);
      m_instance->m_account_settings_model = new AccountSettingsModel(m_instance);

      emit m_instance->linphoneCoreCreated();
    }
  );

  m_promise_watcher.setFuture(m_promise_build);
}

void CoreManager::enableHandlers () {
  m_cbs_timer->start();
}

// -----------------------------------------------------------------------------

void CoreManager::init (QObject *parent, const QString &config_path) {
  if (m_instance)
    return;

  m_instance = new CoreManager(parent, config_path);

  QTimer *timer = m_instance->m_cbs_timer = new QTimer(m_instance);
  timer->setInterval(20);

  QObject::connect(timer, &QTimer::timeout, m_instance, &CoreManager::iterate);
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

  // This one is actually a database but it MUST be set after the zrtp secrets
  // as it allows automatic migration from old version(secrets, xml) to new version (data, sqlite).
  m_core->setZrtpCacheDatabasePath(Paths::getZrtpDataFilepath());

  m_core->setUserCertificatesPath(Paths::getUserCertificatesDirpath());

  m_core->setRootCa(Paths::getRootCaFilepath());
}

void CoreManager::setResourcesPaths () {
  shared_ptr<linphone::Factory> factory = linphone::Factory::get();
  factory->setMspluginsDir(Paths::getPackageMsPluginsDirpath());
  factory->setTopResourcesDir(Paths::getPackageDataDirpath());
}

// -----------------------------------------------------------------------------

void CoreManager::createLinphoneCore (const QString &config_path) {
  qInfo() << QStringLiteral("Launch async linphone core creation.");

  // TODO: activate migration when ready to switch to this new version
  // Paths::migrate();

  setResourcesPaths();

  m_core = linphone::Factory::get()->createCore(m_handlers, Paths::getConfigFilepath(config_path), Paths::getFactoryConfigFilepath());

  m_core->setVideoDisplayFilter("MSOGL");
  m_core->usePreviewWindow(true);

  setDatabasesPaths();
  setOtherPaths();
}

// -----------------------------------------------------------------------------

void CoreManager::iterate () {
  m_instance->lockVideoRender();
  m_instance->m_core->iterate();
  m_instance->unlockVideoRender();
}
