/*
 * CoreManager.cpp
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

#include <QCoreApplication>
#include <QDir>
#include <QSysInfo>
#include <QtConcurrent>
#include <QTimer>

#include "config.h"

#include "app/paths/Paths.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/chat/ChatModel.hpp"
#include "components/contact/VcardModel.hpp"
#include "components/contacts/ContactsListModel.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "components/settings/SettingsModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#if defined(Q_OS_MACOS)
  #include "messages-count-notifier/MessageCountNotifierMacOs.hpp"
#else
  #include "messages-count-notifier/MessageCountNotifierSystemTrayIcon.hpp"
#endif // if defined(Q_OS_MACOS)

#include "CoreHandlers.hpp"
#include "CoreManager.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr int CbsCallInterval = 20;

  constexpr char RcVersionName[] = "rc_version";
  constexpr int RcVersionCurrent = 1;

  // TODO: Remove hardcoded values. Use config directly.
  constexpr char LinphoneDomain[] = "sip.linphone.org";
  constexpr char DefaultContactParameters[] = "message-expires=604800";
  constexpr int DefaultExpires = 3600;
  constexpr char DownloadUrl[] = "https://www.linphone.org/technical-corner/linphone/downloads";
}

// -----------------------------------------------------------------------------

CoreManager *CoreManager::mInstance;

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
    // Do not change this order. :) (Or pray.)
    mInstance->mCallsListModel = new CallsListModel(mInstance);
    mInstance->mContactsListModel = new ContactsListModel(mInstance);
    mInstance->mAccountSettingsModel = new AccountSettingsModel(mInstance);
    mInstance->mSettingsModel = new SettingsModel(mInstance);
    mInstance->mSipAddressesModel = new SipAddressesModel(mInstance);

    {
      MessageCountNotifier *messageCountNotifier = new MessageCountNotifier(mInstance);
      messageCountNotifier->updateUnreadMessageCount();
      QObject::connect(
        messageCountNotifier, &MessageCountNotifier::unreadMessageCountChanged,
        mInstance, &CoreManager::unreadMessageCountChanged
      );
      mInstance->mMessageCountNotifier = messageCountNotifier;
    }

    mInstance->migrate();

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

shared_ptr<ChatModel> CoreManager::getChatModel (const QString &peerAddress, const QString &localAddress) {
  if (peerAddress.isEmpty() || localAddress.isEmpty())
    return nullptr;

  // Create a new chat model.
  QPair<QString, QString> chatModelId{ peerAddress, localAddress };
  if (!mChatModels.contains(chatModelId)) {
    if (
      !mCore->createAddress(Utils::appStringToCoreString(peerAddress)) ||
      !mCore->createAddress(Utils::appStringToCoreString(localAddress))
    ) {
      qWarning() << QStringLiteral("Unable to get chat model from invalid chat model id: (%1, %2).")
        .arg(peerAddress).arg(localAddress);
      return nullptr;
    }

    auto deleter = [this, chatModelId](ChatModel *chatModel) {
      bool removed = mChatModels.remove(chatModelId);
      Q_ASSERT(removed);
      delete chatModel;
    };

    shared_ptr<ChatModel> chatModel(new ChatModel(peerAddress, localAddress), deleter);
    mChatModels[chatModelId] = chatModel;

    emit chatModelCreated(chatModel);

    return chatModel;
  }

  // Returns an existing chat model.
  shared_ptr<ChatModel> chatModel = mChatModels[chatModelId].lock();
  Q_CHECK_PTR(chatModel);
  return chatModel;
}

bool CoreManager::chatModelExists (const QString &peerAddress, const QString &localAddress) {
  return mChatModels.contains({ peerAddress, localAddress });
}

// -----------------------------------------------------------------------------

void CoreManager::init (QObject *parent, const QString &configPath) {
  if (mInstance)
    return;

  mInstance = new CoreManager(parent, configPath);

  QTimer *timer = mInstance->mCbsTimer = new QTimer(mInstance);
  timer->setInterval(CbsCallInterval);

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
    .arg(Utils::coreStringToAppString(mCore->getLogCollectionUploadServerUrl()));
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
      .arg(Utils::coreStringToAppString(PATH)); \
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
  if (mCore->getZrtpSecretsFile().empty() || !Paths::filePathExists(mCore->getZrtpSecretsFile()))
    mCore->setZrtpSecretsFile(Paths::getZrtpSecretsFilePath());
  if (mCore->getUserCertificatesPath().empty() || !Paths::filePathExists(mCore->getUserCertificatesPath()))
    mCore->setUserCertificatesPath(Paths::getUserCertificatesDirPath());
  if (mCore->getRootCa().empty() || !Paths::filePathExists(mCore->getRootCa()))
    mCore->setRootCa(Paths::getRootCaFilePath());
}

void CoreManager::setResourcesPaths () {
  shared_ptr<linphone::Factory> factory = linphone::Factory::get();
  factory->setMspluginsDir(Paths::getPackageMsPluginsDirPath());
  factory->setTopResourcesDir(Paths::getPackageDataDirPath());
}

// -----------------------------------------------------------------------------

void CoreManager::createLinphoneCore (const QString &configPath) {
  qInfo() << QStringLiteral("Launch async core creation.");

  // Migration of configuration and database files from GTK version of Linphone.
  Paths::migrate();

  setResourcesPaths();

  mCore = linphone::Factory::get()->createCore(
    Paths::getConfigFilePath(configPath),
    Paths::getFactoryConfigFilePath(),
    nullptr
  );
  mCore->addListener(mHandlers);

  mCore->setVideoDisplayFilter("MSOGL");
  mCore->usePreviewWindow(true);
  mCore->setUserAgent(
    Utils::appStringToCoreString(
      QStringLiteral(APPLICATION_NAME" Desktop/%1 (%2, Qt %3) LinphoneCore")
        .arg(QCoreApplication::applicationVersion())
        .arg(QSysInfo::prettyProductName())
        .arg(qVersion())
    ),
    mCore->getVersion()
  );

  // Force capture/display.
  // Useful if the app was built without video support.
  // (The capture/display attributes are reset by the core in this case.)
  if (mCore->videoSupported()) {
    shared_ptr<linphone::Config> config = mCore->getConfig();
    config->setInt("video", "capture", 1);
    config->setInt("video", "display", 1);
  }

  mCore->start();

  setDatabasesPaths();
  setOtherPaths();
}

void CoreManager::migrate () {
  shared_ptr<linphone::Config> config = mCore->getConfig();
  int rcVersion = config->getInt(SettingsModel::UiSection, RcVersionName, 0);
  if (rcVersion == RcVersionCurrent)
    return;
  if (rcVersion > RcVersionCurrent) {
    qWarning() << QStringLiteral("RC file version (%1) is more recent than app rc file version (%2)!!!")
      .arg(rcVersion).arg(RcVersionCurrent);
    return;
  }

  qInfo() << QStringLiteral("Migrate from old rc file (%1 to %2).")
    .arg(rcVersion).arg(RcVersionCurrent);

  // Add message_expires param on old proxy configs.
  for (const auto &proxyConfig : mCore->getProxyConfigList()) {
    if (proxyConfig->getDomain() == LinphoneDomain) {
      proxyConfig->setContactParameters(DefaultContactParameters);
      proxyConfig->setExpires(DefaultExpires);
      proxyConfig->done();
    }
  }
  config->setInt(SettingsModel::UiSection, RcVersionName, RcVersionCurrent);
}

// -----------------------------------------------------------------------------

QString CoreManager::getVersion () const {
  return Utils::coreStringToAppString(mCore->getVersion());
}

// -----------------------------------------------------------------------------

int CoreManager::getUnreadMessageCount () const {
  return mMessageCountNotifier ? mMessageCountNotifier->getUnreadMessageCount() : 0;
}

// -----------------------------------------------------------------------------

void CoreManager::iterate () {
  mInstance->lockVideoRender();
  mCore->iterate();
  mInstance->unlockVideoRender();
}

// -----------------------------------------------------------------------------

void CoreManager::handleLogsUploadStateChanged (linphone::Core::LogCollectionUploadState state, const string &info) {
  switch (state) {
    case linphone::Core::LogCollectionUploadState::InProgress:
      break;

    case linphone::Core::LogCollectionUploadState::Delivered:
    case linphone::Core::LogCollectionUploadState::NotDelivered:
      emit logsUploaded(Utils::coreStringToAppString(info));
      break;
  }
}

// -----------------------------------------------------------------------------

QString CoreManager::getDownloadUrl () {
  return DownloadUrl;
}
