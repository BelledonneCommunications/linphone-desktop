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

#include <QDir>
#include <QtConcurrent>
#include <QTimer>

#include "../../app/paths/Paths.hpp"
#include "../../Utils.hpp"

#include "CoreManager.hpp"

#define CBS_CALL_INTERVAL 20

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
  timer->setInterval(CBS_CALL_INTERVAL);

  QObject::connect(timer, &QTimer::timeout, mInstance, &CoreManager::iterate);
}

void CoreManager::uninit () {
  if (mInstance) {
    delete mInstance;
    mInstance = nullptr;
  }
}

// -----------------------------------------------------------------------------

VcardModel *CoreManager::createDetachedVcardModel () {
  VcardModel *vcardModel = new VcardModel(linphone::Factory::get()->createVcard(), false);
  qInfo() << QStringLiteral("Create detached vcard:") << vcardModel;
  return vcardModel;
}

void CoreManager::forceRefreshRegisters () {
  qInfo() << QStringLiteral("Refresh registers.");
  mCore->refreshRegisters();
}

// -----------------------------------------------------------------------------

void CoreManager::setDatabasesPaths () {
  mCore->setFriendsDatabasePath(Paths::getFriendsListFilePath());
  mCore->setCallLogsDatabasePath(Paths::getCallHistoryFilePath());
  mCore->setChatDatabasePath(Paths::getMessageHistoryFilePath());
}

void CoreManager::setOtherPaths () {
  if (mCore->getZrtpSecretsFile().empty())
    mCore->setZrtpSecretsFile(Paths::getZrtpSecretsFilePath());

  if (mCore->getUserCertificatesPath().empty())
    mCore->setUserCertificatesPath(Paths::getUserCertificatesDirPath());

  if (mCore->getRootCa().empty())
    mCore->setRootCa(Paths::getRootCaFilePath());
}

void CoreManager::setResourcesPaths () {
  shared_ptr<linphone::Factory> factory = linphone::Factory::get();
  factory->setMspluginsDir(Paths::getPackageMsPluginsDirPath());
  factory->setTopResourcesDir(Paths::getPackageDataDirPath());
}

// -----------------------------------------------------------------------------

void CoreManager::createLinphoneCore (const QString &configPath) {
  qInfo() << QStringLiteral("Launch async linphone core creation.");

  // TODO: activate migration when ready to switch to this new version
  // Paths::migrate();

  setResourcesPaths();

  mCore = linphone::Factory::get()->createCore(mHandlers, Paths::getConfigFilePath(configPath), Paths::getFactoryConfigFilePath());

  mCore->setVideoDisplayFilter("MSOGL");
  mCore->usePreviewWindow(true);

  setDatabasesPaths();
  setOtherPaths();
}

// -----------------------------------------------------------------------------

QString CoreManager::getVersion () const {
  return ::Utils::linphoneStringToQString(mCore->getVersion());
}

// -----------------------------------------------------------------------------

void CoreManager::iterate () {
  mInstance->lockVideoRender();
  mCore->iterate();
  mInstance->unlockVideoRender();
}
