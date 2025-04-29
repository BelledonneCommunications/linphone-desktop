/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef CORE_MODEL_H_
#define CORE_MODEL_H_

#include <QMap>
#include <QObject>
#include <QSharedPointer>
#include <QString>
#include <QThread>
#include <QTimer>
#include <linphone++/linphone.hh>

#include "model/account/AccountManager.hpp"
#include "model/auth/OIDCModel.hpp"
#include "model/cli/CliModel.hpp"
#include "model/listener/Listener.hpp"
#include "model/logger/LoggerModel.hpp"
#include "model/search/MagicSearchModel.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class CoreModel : public ::Listener<linphone::Core, linphone::CoreListener>,
                  public linphone::CoreListener,
                  public AbstractObject {
	Q_OBJECT
public:
	CoreModel(const QString &configPath, QThread *parent);
	~CoreModel();
	static std::shared_ptr<CoreModel> create(const QString &configPath, QThread *parent);
	static std::shared_ptr<CoreModel> getInstance();

	std::shared_ptr<linphone::Core> getCore();
	std::shared_ptr<LoggerModel> getLogger();

	void start();
	void setConfigPath(QString path);

	QString getFetchConfig(QString filePath, bool *error);
	void useFetchConfig(QString filePath);
	bool setFetchConfig(QString filePath);
	void migrate();

	void searchInMagicSearch(QString filter,
	                         int sourceFlags,
	                         LinphoneEnums::MagicSearchAggregation aggregation,
	                         int maxResults);

	bool mEnd = false;

	std::shared_ptr<linphone::Core> mCore;
	std::shared_ptr<LoggerModel> mLogger;

signals:
	void loggerInitialized();
	void friendCreated(const std::shared_ptr<linphone::Friend> &f);
	void friendRemoved(const std::shared_ptr<linphone::Friend> &f);
	void friendUpdated(const std::shared_ptr<linphone::Friend> &f);
	void bearerAccountAdded();
	void conferenceInfoCreated(const std::shared_ptr<linphone::ConferenceInfo> &confInfo);
	void unreadNotificationsChanged();
	void requestFetchConfig(QString path);
	void requestRestart();
	void enabledLdapAddressBookSaved();
	void magicSearchResultReceived(QString filter);

private:
	QString mConfigPath;
	QTimer *mIterateTimer = nullptr;
	QMap<QString, OIDCModel *> mOpenIdConnections;
	std::shared_ptr<MagicSearchModel> mMagicSearch;

	void setPathBeforeCreation();
	void setPathsAfterCreation();
	void setPathAfterStart();

	static std::shared_ptr<CoreModel> gCoreModel;

	DECLARE_ABSTRACT_OBJECT
	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onAccountAdded(const std::shared_ptr<linphone::Core> &core,
	                            const std::shared_ptr<linphone::Account> &account) override;
	virtual void onAccountRemoved(const std::shared_ptr<linphone::Core> &core,
	                              const std::shared_ptr<linphone::Account> &account) override;
	virtual void onAccountRegistrationStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                               const std::shared_ptr<linphone::Account> &account,
	                                               linphone::RegistrationState state,
	                                               const std::string &message) override;
	virtual void onAuthenticationRequested(const std::shared_ptr<linphone::Core> &core,
	                                       const std::shared_ptr<linphone::AuthInfo> &authInfo,
	                                       linphone::AuthMethod method) override;
	virtual void onCallEncryptionChanged(const std::shared_ptr<linphone::Core> &core,
	                                     const std::shared_ptr<linphone::Call> &call,
	                                     bool on,
	                                     const std::string &authenticationToken) override;
	virtual void onCallLogUpdated(const std::shared_ptr<linphone::Core> &core,
	                              const std::shared_ptr<linphone::CallLog> &callLog) override;
	virtual void onCallStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                const std::shared_ptr<linphone::Call> &call,
	                                linphone::Call::State state,
	                                const std::string &message) override;
	virtual void onCallStatsUpdated(const std::shared_ptr<linphone::Core> &core,
	                                const std::shared_ptr<linphone::Call> &call,
	                                const std::shared_ptr<const linphone::CallStats> &stats) override;
	virtual void onCallCreated(const std::shared_ptr<linphone::Core> &lc,
	                           const std::shared_ptr<linphone::Call> &call) override;
	virtual void onChatRoomRead(const std::shared_ptr<linphone::Core> &core,
	                            const std::shared_ptr<linphone::ChatRoom> &chatRoom) override;
	virtual void onChatRoomStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                    const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                    linphone::ChatRoom::State state) override;
	virtual void
	onConferenceInfoReceived(const std::shared_ptr<linphone::Core> &core,
	                         const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo) override;
	virtual void onConferenceStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                      const std::shared_ptr<linphone::Conference> &conference,
	                                      linphone::Conference::State state) override;

	virtual void onConfiguringStatus(const std::shared_ptr<linphone::Core> &core,
	                                 linphone::ConfiguringState status,
	                                 const std::string &message) override;
	virtual void onDefaultAccountChanged(const std::shared_ptr<linphone::Core> &core,
	                                     const std::shared_ptr<linphone::Account> &account) override;
	virtual void onDtmfReceived(const std::shared_ptr<linphone::Core> &lc,
	                            const std::shared_ptr<linphone::Call> &call,
	                            int dtmf) override;
	virtual void onEcCalibrationResult(const std::shared_ptr<linphone::Core> &core,
	                                   linphone::EcCalibratorStatus status,
	                                   int delayMs) override;
	virtual void onFirstCallStarted(const std::shared_ptr<linphone::Core> &core) override;
	virtual void onGlobalStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                  linphone::GlobalState gstate,
	                                  const std::string &message) override;
	virtual void onIsComposingReceived(const std::shared_ptr<linphone::Core> &core,
	                                   const std::shared_ptr<linphone::ChatRoom> &room) override;
	virtual void onLastCallEnded(const std::shared_ptr<linphone::Core> &core) override;
	virtual void onLogCollectionUploadStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                               linphone::Core::LogCollectionUploadState state,
	                                               const std::string &info) override;
	virtual void onLogCollectionUploadProgressIndication(const std::shared_ptr<linphone::Core> &lc,
	                                                     size_t offset,
	                                                     size_t total) override;
	virtual void onMessageReceived(const std::shared_ptr<linphone::Core> &core,
	                               const std::shared_ptr<linphone::ChatRoom> &room,
	                               const std::shared_ptr<linphone::ChatMessage> &message) override;
	virtual void onMessagesReceived(const std::shared_ptr<linphone::Core> &core,
	                                const std::shared_ptr<linphone::ChatRoom> &room,
	                                const std::list<std::shared_ptr<linphone::ChatMessage>> &messages) override;

	virtual void onNewMessageReaction(const std::shared_ptr<linphone::Core> &core,
	                                  const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                                  const std::shared_ptr<linphone::ChatMessage> &message,
	                                  const std::shared_ptr<const linphone::ChatMessageReaction> &reaction) override;
	virtual void
	onNotifyPresenceReceivedForUriOrTel(const std::shared_ptr<linphone::Core> &core,
	                                    const std::shared_ptr<linphone::Friend> &linphoneFriend,
	                                    const std::string &uriOrTel,
	                                    const std::shared_ptr<const linphone::PresenceModel> &presenceModel) override;
	virtual void onNotifyPresenceReceived(const std::shared_ptr<linphone::Core> &core,
	                                      const std::shared_ptr<linphone::Friend> &linphoneFriend) override;
	virtual void onQrcodeFound(const std::shared_ptr<linphone::Core> &core, const std::string &result) override;
	virtual void onReactionRemoved(const std::shared_ptr<linphone::Core> &core,
	                               const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                               const std::shared_ptr<linphone::ChatMessage> &message,
	                               const std::shared_ptr<const linphone::Address> &address) override;
	virtual void onTransferStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                    const std::shared_ptr<linphone::Call> &call,
	                                    linphone::Call::State state) override;
	virtual void onVersionUpdateCheckResultReceived(const std::shared_ptr<linphone::Core> &core,
	                                                linphone::VersionUpdateCheckResult result,
	                                                const std::string &version,
	                                                const std::string &url) override;
	virtual void onFriendListRemoved(const std::shared_ptr<linphone::Core> &core,
	                                 const std::shared_ptr<linphone::FriendList> &friendList) override;

signals:
	void accountAdded(const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account);
	void accountRemoved(const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account);
	void accountRegistrationStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                     const std::shared_ptr<linphone::Account> &account,
	                                     linphone::RegistrationState state,
	                                     const std::string &message);
	void authenticationRequested(const std::shared_ptr<linphone::Core> &core,
	                             const std::shared_ptr<linphone::AuthInfo> &authInfo,
	                             linphone::AuthMethod method);
	void callEncryptionChanged(const std::shared_ptr<linphone::Core> &core,
	                           const std::shared_ptr<linphone::Call> &call,
	                           bool on,
	                           const std::string &authenticationToken);
	void callLogUpdated(const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::CallLog> &callLog);
	void callStateChanged(const std::shared_ptr<linphone::Core> &core,
	                      const std::shared_ptr<linphone::Call> &call,
	                      linphone::Call::State state,
	                      const std::string &message);
	void callStatsUpdated(const std::shared_ptr<linphone::Core> &core,
	                      const std::shared_ptr<linphone::Call> &call,
	                      const std::shared_ptr<const linphone::CallStats> &stats);
	void callCreated(const std::shared_ptr<linphone::Call> &call);
	void chatRoomRead(const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::ChatRoom> &chatRoom);
	void chatRoomStateChanged(const std::shared_ptr<linphone::Core> &core,
	                          const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                          linphone::ChatRoom::State state);
	void conferenceInfoReceived(const std::shared_ptr<linphone::Core> &core,
	                            const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo);
	void conferenceStateChanged(const std::shared_ptr<linphone::Core> &core,
	                            const std::shared_ptr<linphone::Conference> &conference,
	                            linphone::Conference::State state);
	void configuringStatus(const std::shared_ptr<linphone::Core> &core,
	                       linphone::ConfiguringState status,
	                       const std::string &message);
	void defaultAccountChanged(const std::shared_ptr<linphone::Core> &core,
	                           const std::shared_ptr<linphone::Account> &account);
	void dtmfReceived(const std::shared_ptr<linphone::Core> &lc, const std::shared_ptr<linphone::Call> &call, int dtmf);
	void
	ecCalibrationResult(const std::shared_ptr<linphone::Core> &core, linphone::EcCalibratorStatus status, int delayMs);
	void firstCallStarted();
	void globalStateChanged(const std::shared_ptr<linphone::Core> &core,
	                        linphone::GlobalState gstate,
	                        const std::string &message);
	void isComposingReceived(const std::shared_ptr<linphone::Core> &core,
	                         const std::shared_ptr<linphone::ChatRoom> &room);
	void lastCallEnded();
	void logCollectionUploadStateChanged(const std::shared_ptr<linphone::Core> &core,
	                                     linphone::Core::LogCollectionUploadState state,
	                                     const std::string &info);
	void logCollectionUploadProgressIndication(const std::shared_ptr<linphone::Core> &lc, size_t offset, size_t total);
	void messageReceived(const std::shared_ptr<linphone::Core> &core,
	                     const std::shared_ptr<linphone::ChatRoom> &room,
	                     const std::shared_ptr<linphone::ChatMessage> &message);
	void messagesReceived(const std::shared_ptr<linphone::Core> &core,
	                      const std::shared_ptr<linphone::ChatRoom> &room,
	                      const std::list<std::shared_ptr<linphone::ChatMessage>> &messages);
	void newMessageReaction(const std::shared_ptr<linphone::Core> &core,
	                        const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                        const std::shared_ptr<linphone::ChatMessage> &message,
	                        const std::shared_ptr<const linphone::ChatMessageReaction> &reaction);
	void notifyPresenceReceivedForUriOrTel(const std::shared_ptr<linphone::Core> &core,
	                                       const std::shared_ptr<linphone::Friend> &linphoneFriend,
	                                       const std::string &uriOrTel,
	                                       const std::shared_ptr<const linphone::PresenceModel> &presenceModel);
	void notifyPresenceReceived(const std::shared_ptr<linphone::Core> &core,
	                            const std::shared_ptr<linphone::Friend> &linphoneFriend);
	void qrcodeFound(const std::shared_ptr<linphone::Core> &core, const std::string &result);
	void reactionRemoved(const std::shared_ptr<linphone::Core> &core,
	                     const std::shared_ptr<linphone::ChatRoom> &chatRoom,
	                     const std::shared_ptr<linphone::ChatMessage> &message,
	                     const std::shared_ptr<const linphone::Address> &address);
	void transferStateChanged(const std::shared_ptr<linphone::Core> &core,
	                          const std::shared_ptr<linphone::Call> &call,
	                          linphone::Call::State state);
	void versionUpdateCheckResultReceived(const std::shared_ptr<linphone::Core> &core,
	                                      linphone::VersionUpdateCheckResult result,
	                                      const std::string &version,
	                                      const std::string &url);
	void friendListRemoved(const std::shared_ptr<linphone::Core> &core,
	                       const std::shared_ptr<linphone::FriendList> &friendList);
};

#endif
