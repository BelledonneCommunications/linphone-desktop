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

CoreManager *CoreManager::mInstance = nullptr;

CoreManager::CoreManager (QObject *parent, const QString &configPath) : QObject(parent), mHandlers(make_shared<CoreHandlers>()) {
  mPromiseBuild = QtConcurrent::run(this, &CoreManager::createLinphoneCore, configPath);

  QObject::connect(
    &mPromiseWatcher, &QFutureWatcher<void>::finished, this, []() {
      mInstance->mCallsListModel = new CallsListModel(mInstance);
      mInstance->mContactsListModel = new ContactsListModel(mInstance);
      mInstance->mSipAddressesModel = new SipAddressesModel(mInstance);
      mInstance->mSettingsModel = new SettingsModel(mInstance);
      mInstance->mAccountSettingsModel = new AccountSettingsModel(mInstance);

      emit mInstance->linphoneCoreCreated();
    }
  );

  mPromiseWatcher.setFuture(mPromiseBuild);
}

void CoreManager::enableHandlers () {
  mCbsTimer->start();
}

// -----------------------------------------------------------------------------

void CoreManager::init (QObject *parent, const QString &configPath) {
  if (mInstance)
    return;

  mInstance = new CoreManager(parent, configPath);

  QTimer *timer = mInstance->mCbsTimer = new QTimer(mInstance);
  timer->setInterval(20);

  QObject::connect(timer, &QTimer::timeout, mInstance, &CoreManager::iterate);
}

// -----------------------------------------------------------------------------

VcardModel *CoreManager::createDetachedVcardModel () {
  return new VcardModel(linphone::Factory::get()->createVcard());
}

void CoreManager::forceRefreshRegisters () {
  qInfo() << QStringLiteral("Refresh registers.");
  mInstance->mCore->refreshRegisters();
}

// -----------------------------------------------------------------------------

void CoreManager::setDatabasesPaths () {
  mCore->setFriendsDatabasePath(Paths::getFriendsListFilepath());
  mCore->setCallLogsDatabasePath(Paths::getCallHistoryFilepath());
  mCore->setChatDatabasePath(Paths::getMessageHistoryFilepath());
}

void CoreManager::setOtherPaths () {
  if (mCore->getZrtpSecretsFile().empty())
	  mCore->setZrtpSecretsFile(Paths::getZrtpSecretsFilepath());

  // This one is actually a database but it MUST be set after the zrtp secrets
  // as it allows automatic migration from old version(secrets, xml) to new version (data, sqlite).
  mCore->setZrtpCacheDatabasePath(Paths::getZrtpDataFilepath());

  if (mCore->getUserCertificatesPath().empty())
	  mCore->setUserCertificatesPath(Paths::getUserCertificatesDirpath());

  if (mCore->getRootCa().empty())
	  mCore->setRootCa(Paths::getRootCaFilepath());
}

void CoreManager::setResourcesPaths () {
  shared_ptr<linphone::Factory> factory = linphone::Factory::get();
  factory->setMspluginsDir(Paths::getPackageMsPluginsDirpath());
  factory->setTopResourcesDir(Paths::getPackageDataDirpath());
}

// -----------------------------------------------------------------------------

void CoreManager::createLinphoneCore (const QString &configPath) {
  qInfo() << QStringLiteral("Launch async linphone core creation.");

  // TODO: activate migration when ready to switch to this new version
  // Paths::migrate();

  setResourcesPaths();

  mCore = linphone::Factory::get()->createCore(mHandlers, Paths::getConfigFilepath(configPath), Paths::getFactoryConfigFilepath());

  mCore->setVideoDisplayFilter("MSOGL");
  mCore->usePreviewWindow(true);

  setDatabasesPaths();
  setOtherPaths();
}

// -----------------------------------------------------------------------------

void CoreManager::iterate () {
  mInstance->lockVideoRender();
  mInstance->mCore->iterate();
  mInstance->unlockVideoRender();
}
