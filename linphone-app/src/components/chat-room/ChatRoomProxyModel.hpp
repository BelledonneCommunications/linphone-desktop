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

#ifndef CHAT_ROOM_PROXY_MODEL_H_
#define CHAT_ROOM_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "ChatRoomModel.hpp"

// =============================================================================

class QWindow;

class ChatRoomProxyModel : public QSortFilterProxyModel {
	class ChatRoomModelFilter;
	
	Q_OBJECT
	
	Q_PROPERTY(QString peerAddress READ getPeerAddress WRITE setPeerAddress NOTIFY peerAddressChanged)
	Q_PROPERTY(QString localAddress READ getLocalAddress WRITE setLocalAddress NOTIFY localAddressChanged)
	Q_PROPERTY(QString fullPeerAddress READ getFullPeerAddress WRITE setFullPeerAddress NOTIFY fullPeerAddressChanged)
	Q_PROPERTY(QString fullLocalAddress READ getFullLocalAddress WRITE setFullLocalAddress NOTIFY fullLocalAddressChanged)
	Q_PROPERTY(ChatRoomModel *chatRoomModel READ getChatRoomModel WRITE setChatRoomModel NOTIFY chatRoomModelChanged)
	Q_PROPERTY(QList<QString> composers READ getComposers NOTIFY isRemoteComposingChanged)
	Q_PROPERTY(QString cachedText READ getCachedText)
	
	Q_PROPERTY(QString filterText MEMBER mFilterText WRITE setFilterText NOTIFY filterTextChanged)
	Q_PROPERTY(bool markAsReadEnabled READ markAsReadEnabled WRITE enableMarkAsRead NOTIFY markAsReadEnabledChanged)// Focus is at end of the list. Used to reset message count if not at end
	
	Q_PROPERTY(bool isCall MEMBER mIsCall WRITE setIsCall NOTIFY isCallChanged)
	
public:
	ChatRoomProxyModel (QObject *parent = Q_NULLPTR);
	~ChatRoomProxyModel();
	
	int getEntryTypeFilter ();
	Q_INVOKABLE void setEntryTypeFilter (int type);
	Q_INVOKABLE void setFilterText(const QString& text);
	
	Q_INVOKABLE QString getDisplayNameComposers()const;
	Q_INVOKABLE QVariant getAt(int row);
	
	void setIsCall(const bool& isCall);
	
	
	Q_INVOKABLE void loadMoreEntriesAsync ();
	Q_INVOKABLE void loadMoreEntries ();
	
	Q_INVOKABLE void removeAllEntries ();
	Q_INVOKABLE void removeRow (int index);
	Q_INVOKABLE void deleteChatRoom();
	
	Q_INVOKABLE void sendMessage (const QString &message);
	Q_INVOKABLE void forwardMessage(ChatMessageModel * model);
	Q_INVOKABLE void compose (const QString& text);
	Q_INVOKABLE void resetMessageCount();
	
	Q_INVOKABLE int loadTillMessage(ChatMessageModel * message);// Load all entries till message and return its index in displayed list (-1 if not found)
	
public slots:
	void onMoreEntriesLoaded(const int& count);
	
signals:
	void peerAddressChanged (const QString &peerAddress);
	void localAddressChanged (const QString &localAddress);
	void fullPeerAddressChanged (const QString &fullPeerAddress);
	void fullLocalAddressChanged (const QString &fullLocalAddress);
	bool isRemoteComposingChanged ();
	void markAsReadEnabledChanged();
	//bool isSecureChanged(bool secure);
	
	void chatRoomModelChanged();
	void chatRoomDeleted();
	
	void moreEntriesLoaded (int n);
	
	void entryTypeFilterChanged (int type);
	void filterTextChanged();
	void isCallChanged();
	
protected:
	bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
private:
	QString getPeerAddress () const;
	void setPeerAddress (const QString &peerAddress);
	
	QString getLocalAddress () const;
	void setLocalAddress (const QString &localAddress);
	
	QString getFullPeerAddress () const;
	void setFullPeerAddress (const QString &peerAddress);
	
	QString getFullLocalAddress () const;
	void setFullLocalAddress (const QString &localAddress);
	
	bool markAsReadEnabled() const;
	void enableMarkAsRead(const bool& enable);
	
	ChatRoomModel *getChatRoomModel() const;
	void setChatRoomModel (ChatRoomModel *chatRoomModel);
	
	QList<QString> getComposers () const;
	
	QString getCachedText() const;
	
	void reload (ChatRoomModel *chatRoomModel);
	
	void handleIsActiveChanged (QWindow *window);
	
	void handleIsRemoteComposingChanged ();
	void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
	void handleMessageSent (const std::shared_ptr<linphone::ChatMessage> &message);
	
	int mMaxDisplayedEntries = EntriesChunkSize;
	int mEntryTypeFilter = ChatRoomModel::EntryType::GenericEntry;
	
	QString mPeerAddress;
	QString mLocalAddress;
	QString mFullPeerAddress;
	QString mFullLocalAddress;
	static QString gCachedText;
	bool mMarkAsReadEnabled;
	bool mIsCall = false;
	
	QString mFilterText;
	
	QSharedPointer<ChatRoomModel> mChatRoomModel;
	
	static constexpr int EntriesChunkSize = 50;
};

#endif // CHAT_ROOM_PROXY_MODEL_H_
