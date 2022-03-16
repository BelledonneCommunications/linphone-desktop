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

#ifndef CALLS_LIST_MODEL_H_
#define CALLS_LIST_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>

#include "components/call/CallModel.hpp"
#include "utils/LinphoneEnums.hpp"

// =============================================================================

class ChatRoomModel;
class CoreHandlers;

class CallsListModel : public QAbstractListModel {
	Q_OBJECT
	
public:
	CallsListModel (QObject *parent = Q_NULLPTR);
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	
	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	CallModel *findCallModelFromPeerAddress (const QString &peerAddress) const;
	
	void askForTransfer (CallModel *callModel);
	void askForAttendedTransfer (CallModel *callModel);
	
	Q_INVOKABLE void launchAudioCall (const QString &sipAddress, const QString& prepareTransfertAddress = "", const QHash<QString, QString> &headers = {}) const;
	Q_INVOKABLE void launchSecureAudioCall (const QString &sipAddress, LinphoneEnums::MediaEncryption encryption, const QHash<QString, QString> &headers = {}, const QString& prepareTransfertAddress = "") const;
	Q_INVOKABLE void launchVideoCall (const QString &sipAddress, const QString& prepareTransfertAddress = "") const;
	Q_INVOKABLE ChatRoomModel* launchSecureChat (const QString &sipAddress) const;
	Q_INVOKABLE QVariantMap launchChat(const QString &sipAddress, const int& securityLevel) const;
	Q_INVOKABLE ChatRoomModel* createChat (const QString &participantAddress) const;
	Q_INVOKABLE ChatRoomModel* createChat (const CallModel * ) const;
	Q_INVOKABLE bool createSecureChat (const QString& subject, const QString &participantAddress) const;
	
	QVariantMap createChatRoom(const QString& subject, const int& securityLevel, std::shared_ptr<linphone::Address> localAddress, const QVariantList& participants, const bool& selectAfterCreation) const;
	Q_INVOKABLE QVariantMap createChatRoom(const QString& subject, const int& securityLevel, const QVariantList& participants, const bool& selectAfterCreation) const;
	
	Q_INVOKABLE int getRunningCallsNumber () const;
	
	Q_INVOKABLE void terminateAllCalls () const;
	Q_INVOKABLE void terminateCall (const QString& sipAddress) const;
	
	static std::list<std::shared_ptr<linphone::CallLog>> getCallHistory(const QString& peerAddress, const QString& localAddress);	
		
signals:
	void callRunning (int index, CallModel *callModel);
	void callTransferAsked (CallModel *callModel);
	void callAttendedTransferAsked (CallModel *callModel);
	
	void callMissed (CallModel *callModel);
	
private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);
	
	void addCall (const std::shared_ptr<linphone::Call> &call);
	void removeCall (const std::shared_ptr<linphone::Call> &call);
	void removeCallCb (CallModel *callModel);
	
	QList<CallModel *> mList;
	
	std::shared_ptr<CoreHandlers> mCoreHandlers;
};

#endif // CALLS_LIST_MODEL_H_
