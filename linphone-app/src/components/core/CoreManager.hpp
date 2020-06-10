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

#ifndef CORE_MANAGER_H_
#define CORE_MANAGER_H_

#include <linphone++/linphone.hh>
#include <QObject>
#include <QString>
#include <QHash>
#include <QMutex>

// =============================================================================

class QTimer;

class AccountSettingsModel;
class CallsListModel;
class ChatModel;
class ContactsListModel;
class CoreHandlers;
class EventCountNotifier;
class SettingsModel;
class SipAddressesModel;
class VcardModel;

class CoreManager : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString version READ getVersion CONSTANT);
  Q_PROPERTY(QString downloadUrl READ getDownloadUrl CONSTANT);
  Q_PROPERTY(int eventCount READ getEventCount NOTIFY eventCountChanged);

public:
  bool started () const {
    return mStarted;
  }

  std::shared_ptr<linphone::Core> getCore () {
    Q_CHECK_PTR(mCore);
    return mCore;
  }

  std::shared_ptr<CoreHandlers> getHandlers () {
    Q_CHECK_PTR(mHandlers);
    return mHandlers;
  }

  std::shared_ptr<ChatModel> getChatModel (const QString &peerAddress, const QString &localAddress);
  bool chatModelExists (const QString &sipAddress, const QString &localAddress);

  // ---------------------------------------------------------------------------
  // Video render lock.
  // ---------------------------------------------------------------------------

  void lockVideoRender () {
    mMutexVideoRender.lock();
  }

  void unlockVideoRender () {
    mMutexVideoRender.unlock();
  }

  // ---------------------------------------------------------------------------
  // Singleton models.
  // ---------------------------------------------------------------------------

  CallsListModel *getCallsListModel () const {
    Q_CHECK_PTR(mCallsListModel);
    return mCallsListModel;
  }

  ContactsListModel *getContactsListModel () const {
    Q_CHECK_PTR(mContactsListModel);
    return mContactsListModel;
  }

  SipAddressesModel *getSipAddressesModel () const {
    Q_CHECK_PTR(mSipAddressesModel);
    return mSipAddressesModel;
  }

  SettingsModel *getSettingsModel () const {
    Q_CHECK_PTR(mSettingsModel);
    return mSettingsModel;
  }

  AccountSettingsModel *getAccountSettingsModel () const {
    Q_CHECK_PTR(mAccountSettingsModel);
    return mAccountSettingsModel;
  }

  // ---------------------------------------------------------------------------
  // Initialization.
  // ---------------------------------------------------------------------------

  static void init (QObject *parent, const QString &configPath);
  static void uninit ();

  static CoreManager *getInstance () {
    Q_CHECK_PTR(mInstance);
    return mInstance;
  }

  // ---------------------------------------------------------------------------

  // Must be used in a qml scene.
  // Warning: The ownership of `VcardModel` is `QQmlEngine::JavaScriptOwnership` by default.
  Q_INVOKABLE VcardModel *createDetachedVcardModel () const;

  Q_INVOKABLE void forceRefreshRegisters ();

  Q_INVOKABLE void sendLogs () const;
  Q_INVOKABLE void cleanLogs () const;

  int getMissedCallCount(const QString &peerAddress, const QString &localAddress) const;// Get missed call count from a chat (useful for showing bubbles on Timelines)
  int getMissedCallCountFromLocal(const QString &localAddress) const;// Get missed call count from a chat (useful for showing bubbles on Timelines)

signals:
  void coreCreated ();
  void coreStarted ();

  void chatModelCreated (const std::shared_ptr<ChatModel> &chatModel);

  void logsUploaded (const QString &url);

  void eventCountChanged (int count);

private:
  CoreManager (QObject *parent, const QString &configPath);

  void setDatabasesPaths ();
  void setOtherPaths ();
  void setResourcesPaths ();

  void createLinphoneCore (const QString &configPath);
  void migrate ();

  QString getVersion () const;

  int getEventCount () const;

  void iterate ();

  void handleLogsUploadStateChanged (linphone::Core::LogCollectionUploadState state, const std::string &info);

  static QString getDownloadUrl ();

  std::shared_ptr<linphone::Core> mCore;
  std::shared_ptr<CoreHandlers> mHandlers;

  bool mStarted = false;

  CallsListModel *mCallsListModel = nullptr;
  ContactsListModel *mContactsListModel = nullptr;
  SipAddressesModel *mSipAddressesModel = nullptr;
  SettingsModel *mSettingsModel = nullptr;
  AccountSettingsModel *mAccountSettingsModel = nullptr;

  EventCountNotifier *mEventCountNotifier = nullptr;

  QHash<QPair<QString, QString>, std::weak_ptr<ChatModel>> mChatModels;

  QTimer *mCbsTimer = nullptr;

  QMutex mMutexVideoRender;

  static CoreManager *mInstance;
};

#endif // CORE_MANAGER_H_
