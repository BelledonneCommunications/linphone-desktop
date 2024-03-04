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
#include <QSharedPointer>

// =============================================================================

class QTimer;

class AbstractEventCountNotifier;
class AccountSettingsModel;
class CallsListModel;
class ChatModel;
class ChatRoomModel;
class ContactsListModel;
class ContactsImporterListModel;
class CoreHandlers;
class EventCountNotifier;
class HistoryModel;
class LdapListModel;
class RecorderManager;
class EmojisSettingsModel;
class SettingsModel;
class SipAddressesModel;
class VcardModel;
class TimelineListModel;


class CoreManager : public QObject {
	Q_OBJECT;
	
	Q_PROPERTY(QString version READ getVersion CONSTANT)
	Q_PROPERTY(QString downloadUrl READ getDownloadUrl CONSTANT)
	Q_PROPERTY(int eventCount READ getEventCount NOTIFY eventCountChanged)
	Q_PROPERTY(int callLogsCount READ getCallLogsCount NOTIFY callLogsCountChanged)
	Q_PROPERTY(bool initialized READ isInitialized NOTIFY coreManagerInitialized)
	
public:
	bool started () const {
		return mStarted;
	}
	
	std::shared_ptr<linphone::Core> getCore () {
		return mCore;
	}
	
	QSharedPointer<CoreHandlers> getHandlers () {
		Q_CHECK_PTR(mHandlers);
		return mHandlers;
	}
	
	HistoryModel* getHistoryModel();
	RecorderManager* getRecorderManager();
	
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
	
	ContactsImporterListModel *getContactsImporterListModel () const {
		Q_CHECK_PTR(mContactsImporterListModel);
		return mContactsImporterListModel;
	}
	
	TimelineListModel *getTimelineListModel () const {
		return mTimelineListModel;
	}
	
	SipAddressesModel *getSipAddressesModel () const {
		Q_CHECK_PTR(mSipAddressesModel);
		return mSipAddressesModel;
	}
	
	SettingsModel *getSettingsModel () const {
		Q_CHECK_PTR(mSettingsModel);
		return mSettingsModel;
	}
	EmojisSettingsModel *getEmojisSettingsModel () const {
		return mEmojisSettingsModel;
	}
	
	AccountSettingsModel *getAccountSettingsModel () const {
		Q_CHECK_PTR(mAccountSettingsModel);
		return mAccountSettingsModel;
	}
	LdapListModel *getLdapListModel() const{
		return mLdapListModel;
	}
	
	AbstractEventCountNotifier * getEventCountNotifier();
	
	ChatModel * getChatModel() const{
		return mChatModel;
	}
	
	static CoreManager *getInstance ();
	
	// ---------------------------------------------------------------------------
	// Initialization.
	// ---------------------------------------------------------------------------
	
	static void init (QObject *parent, const QString &configPath);
	static void uninit ();
	
	// ---------------------------------------------------------------------------
	
	// Must be used in a qml scene.
	// Warning: The ownership of `VcardModel` is `QQmlEngine::JavaScriptOwnership` by default.
	Q_INVOKABLE VcardModel *createDetachedVcardModel () const;
	
	Q_INVOKABLE void forceRefreshRegisters ();
	void resetMissedCallsCount();// Reset current default account or core if no default.
	void stateChanged(Qt::ApplicationState pState);
	
	Q_INVOKABLE void sendLogs () const;
	Q_INVOKABLE void cleanLogs () const;
	
	int getCallLogsCount() const;
	
	std::list<std::shared_ptr<linphone::Account>> getAccountList()const;
	
	static bool isInstanciated(){return mInstance!=nullptr;}
	bool isInitialized() const;
	
	Q_INVOKABLE bool isLastRemoteProvisioningGood();
	Q_INVOKABLE QString getUserAgent()const;
	void updateUserAgent();
	void addingAccount(const std::shared_ptr<const linphone::AccountParams> params);
	
public slots:
	void initCoreManager();
	void startIterate();
	void stopIterate();
	void setLastRemoteProvisioningState(const linphone::ConfiguringState& state);
	void createLinphoneCore (const QString &configPath);// In order to delay creation
	void handleChatRoomCreated(const QSharedPointer<ChatRoomModel> &chatRoomModel);
	
signals:
	void coreManagerInitialized ();
	
	void chatRoomModelCreated (const QSharedPointer<ChatRoomModel> &chatRoomModel);
	void historyModelCreated (HistoryModel *historyModel);
	void recorderManagerCreated(RecorderManager *recorderModel);
	
	void logsUploaded (const QString &url);
	
	void eventCountChanged ();
	void callLogsCountChanged();
    void remoteProvisioningFailed();
	void userInitiatedVersionUpdateCheckResult(int result, QString version = nullptr, QString url = nullptr);

private:
	CoreManager (QObject *parent, const QString &configPath);
	~CoreManager ();
	
	void setDatabasesPaths ();
	void setOtherPaths ();
	void setResourcesPaths ();
	
	void migrate ();
	
	QString getVersion () const;
	
	int getEventCount () const;
	
	void iterate ();
	
	void handleLogsUploadStateChanged (linphone::Core::LogCollectionUploadState state, const std::string &info);
	
	static QString getDownloadUrl ();
	
	std::shared_ptr<linphone::Core> mCore;
	QSharedPointer<CoreHandlers> mHandlers;
	
	bool mStarted = false;
	linphone::ConfiguringState mLastRemoteProvisioningState;
	
	CallsListModel *mCallsListModel = nullptr;
	ContactsListModel *mContactsListModel = nullptr;
	ContactsImporterListModel *mContactsImporterListModel = nullptr;
	TimelineListModel *mTimelineListModel = nullptr;
	ChatModel *mChatModel = nullptr;
	
	SipAddressesModel *mSipAddressesModel = nullptr;
	SettingsModel *mSettingsModel = nullptr;
	EmojisSettingsModel *mEmojisSettingsModel =nullptr;
	AccountSettingsModel *mAccountSettingsModel = nullptr;
	
	EventCountNotifier *mEventCountNotifier = nullptr;

	HistoryModel * mHistoryModel = nullptr;
	LdapListModel *mLdapListModel = nullptr;
	RecorderManager* mRecorderManager = nullptr;
	
	QTimer *mCbsTimer = nullptr;
	
	QMutex mMutexVideoRender;
	
	static CoreManager *mInstance;
};

#endif // CORE_MANAGER_H_
