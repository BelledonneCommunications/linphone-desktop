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

#include <QCoreApplication>
#include <QDir>
#include <QtConcurrent>
#include <QTimer>

#include "../../app/paths/Paths.hpp"
#include "../../utils/Utils.hpp"
#include "MessagesCountNotifier.hpp"

#include "CoreManager.hpp"

#define CBS_CALL_INTERVAL 20

#define DOWNLOAD_URL "https://www.linphone.org/technical-corner/linphone/downloads"

using namespace std;

// =============================================================================

CoreManager *CoreManager::mInstance = nullptr;

CoreManager::CoreManager (QObject *parent, const QString &configPath) :
  QObject(parent), mHandlers(make_shared<CoreHandlers>(this)) {
  mPromiseBuild = QtConcurrent::run(this, &CoreManager::createLinphoneCore, configPath);

  QObject::connect(&mPromiseWatcher, &QFutureWatcher<void>::finished, this, [] {
    qInfo() << QStringLiteral("Core created. Enable iterate.");
    mInstance->mCbsTimer->start();

    emit mInstance->coreCreated();
  });

  CoreHandlers *coreHandlers = mHandlers.get();

  QObject::connect(coreHandlers, &CoreHandlers::coreStarted, this, [] {
    new MessagesCountNotifier(mInstance);

    mInstance->mCallsListModel = new CallsListModel(mInstance);
    mInstance->mContactsListModel = new ContactsListModel(mInstance);
    mInstance->mSipAddressesModel = new SipAddressesModel(mInstance);
    mInstance->mSettingsModel = new SettingsModel(mInstance);
    mInstance->mAccountSettingsModel = new AccountSettingsModel(mInstance);

    mInstance->mStarted = true;

    emit mInstance->coreStarted();
  });

  QObject::connect(
    coreHandlers, &CoreHandlers::logsUploadStateChanged,
    this, &CoreManager::handleLogsUploadStateChanged
  );

  mPromiseWatcher.setFuture(mPromiseBuild);
}

// -----------------------------------------------------------------------------

shared_ptr<ChatModel> CoreManager::getChatModelFromSipAddress (const QString &sipAddress) {
  if (!sipAddress.length())
    return nullptr;

  // Create a new chat model.
  if (!mChatModels.contains(sipAddress)) {
    Q_ASSERT(mCore->createAddress(::Utils::appStringToCoreString(sipAddress)) != nullptr);

    auto deleter = [this](ChatModel *chatModel) {
        mChatModels.remove(chatModel->getSipAddress());
      };

    shared_ptr<ChatModel> chatModel(new ChatModel(sipAddress), deleter);
    mChatModels[sipAddress] = chatModel;

    emit chatModelCreated(chatModel);

    return chatModel;
  }

  // Returns an existing chat model.
  shared_ptr<ChatModel> chatModel = mChatModels[sipAddress].lock();
  Q_CHECK_PTR(chatModel.get());
  return chatModel;
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

VcardModel *CoreManager::createDetachedVcardModel () const {
  VcardModel *vcardModel = new VcardModel(linphone::Factory::get()->createVcard(), false);
  qInfo() << QStringLiteral("Create detached vcard:") << vcardModel;
  return vcardModel;
}

void CoreManager::forceRefreshRegisters () {
  Q_CHECK_PTR(mCore);

  qInfo() << QStringLiteral("Refresh registers.");
  mCore->refreshRegisters();
}

// -----------------------------------------------------------------------------

void CoreManager::sendLogs () const {
  Q_CHECK_PTR(mCore);

  qInfo() << QStringLiteral("Send logs to: `%1`.")
    .arg(::Utils::coreStringToAppString(mCore->getLogCollectionUploadServerUrl()));
  mCore->uploadLogCollection();
}

void CoreManager::cleanLogs () const {
  Q_CHECK_PTR(mCore);

  mCore->resetLogCollection();
}

// -----------------------------------------------------------------------------

#define SET_DATABASE_PATH(DATABASE, PATH) \
  do { \
    qInfo() << QStringLiteral("Set `%1` path: `%2`") \
      .arg( # DATABASE) \
      .arg(::Utils::coreStringToAppString(PATH)); \
    mCore->set ## DATABASE ## DatabasePath(PATH); \
  } while (0);

void CoreManager::setDatabasesPaths () {
  SET_DATABASE_PATH(Friends, Paths::getFriendsListFilePath());
  SET_DATABASE_PATH(CallLogs, Paths::getCallHistoryFilePath());
  SET_DATABASE_PATH(Chat, Paths::getMessageHistoryFilePath());
}

#undef SET_DATABASE_PATH

// -----------------------------------------------------------------------------

void CoreManager::setOtherPaths () {
  if (mCore->getZrtpSecretsFile().empty() || !Paths::filePathExists(mCore->getZrtpSecretsFile())) {
    mCore->setZrtpSecretsFile(Paths::getZrtpSecretsFilePath());
  }
  if (mCore->getUserCertificatesPath().empty() || !Paths::filePathExists(mCore->getUserCertificatesPath())) {
    mCore->setUserCertificatesPath(Paths::getUserCertificatesDirPath());
  }
  if (mCore->getRootCa().empty() || !Paths::filePathExists(mCore->getRootCa())) {
    mCore->setRootCa(Paths::getRootCaFilePath());
  }
}

void CoreManager::setResourcesPaths () {
  shared_ptr<linphone::Factory> factory = linphone::Factory::get();
  factory->setMspluginsDir(Paths::getPackageMsPluginsDirPath());
  factory->setTopResourcesDir(Paths::getPackageDataDirPath());
}

// -----------------------------------------------------------------------------

void CoreManager::createLinphoneCore (const QString &configPath) {
  qInfo() << QStringLiteral("Launch async linphone core creation.");

  // Migration of configuration and database files from GTK version of Linphone.
  Paths::migrate();

  setResourcesPaths();

  mCore = linphone::Factory::get()->createCore(mHandlers, Paths::getConfigFilePath(configPath), Paths::getFactoryConfigFilePath());

  mCore->setVideoDisplayFilter("MSOGL");
  mCore->usePreviewWindow(true);
  mCore->setUserAgent("Linphone Desktop", ::Utils::appStringToCoreString(QCoreApplication::applicationVersion()));

  // Force capture/display.
  // Useful if the app was built without video support.
  // (The capture/display attributes are reset by the core in this case.)
  if (mCore->videoSupported()) {
    shared_ptr<linphone::Config> config = mCore->getConfig();
    config->setInt("video", "capture", 1);
    config->setInt("video", "display", 1);
  }

  setDatabasesPaths();
  setOtherPaths();
}

// -----------------------------------------------------------------------------

QString CoreManager::getVersion () const {
  return ::Utils::coreStringToAppString(mCore->getVersion());
}

// -----------------------------------------------------------------------------

void CoreManager::iterate () {
  mInstance->lockVideoRender();
  mCore->iterate();
  mInstance->unlockVideoRender();
}

// -----------------------------------------------------------------------------

void CoreManager::handleLogsUploadStateChanged (linphone::CoreLogCollectionUploadState state, const string &info) {
  switch (state) {
    case linphone::CoreLogCollectionUploadStateInProgress:
      break;

    case linphone::CoreLogCollectionUploadStateDelivered:
    case linphone::CoreLogCollectionUploadStateNotDelivered:
      emit logsUploaded(::Utils::coreStringToAppString(info));
      break;
  }
}

// -----------------------------------------------------------------------------

QString CoreManager::getDownloadUrl () {
  return QStringLiteral(DOWNLOAD_URL);
}
