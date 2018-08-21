/*
 * ChatProxyModel.hpp
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

#ifndef CHAT_PROXY_MODEL_H_
#define CHAT_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "ChatModel.hpp"

// =============================================================================

class QWindow;

class ChatProxyModel : public QSortFilterProxyModel {
  class ChatModelFilter;

  Q_OBJECT;

  Q_PROPERTY(QString peerAddress READ getPeerAddress WRITE setPeerAddress NOTIFY peerAddressChanged);
  Q_PROPERTY(QString localAddress READ getLocalAddress WRITE setLocalAddress NOTIFY localAddressChanged);
  Q_PROPERTY(bool isRemoteComposing READ getIsRemoteComposing NOTIFY isRemoteComposingChanged);

public:
  ChatProxyModel (QObject *parent = Q_NULLPTR);

  Q_INVOKABLE void loadMoreEntries ();
  Q_INVOKABLE void setEntryTypeFilter (ChatModel::EntryType type);
  Q_INVOKABLE void removeEntry (int id);

  Q_INVOKABLE void removeAllEntries ();

  Q_INVOKABLE void sendMessage (const QString &message);
  Q_INVOKABLE void resendMessage (int id);

  Q_INVOKABLE void sendFileMessage (const QString &path);

  Q_INVOKABLE void downloadFile (int id);
  Q_INVOKABLE void openFile (int id);
  Q_INVOKABLE void openFileDirectory (int id);

  Q_INVOKABLE void compose ();

signals:
  void peerAddressChanged (const QString &peerAddress);
  void localAddressChanged (const QString &localAddress);
  bool isRemoteComposingChanged (bool status);

  void moreEntriesLoaded (int n);

  void entryTypeFilterChanged (ChatModel::EntryType type);

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;

private:
  QString getPeerAddress () const;
  void setPeerAddress (const QString &peerAddress);

  QString getLocalAddress () const;
  void setLocalAddress (const QString &localAddress);

  bool getIsRemoteComposing () const;

  void reload ();

  void handleIsActiveChanged (QWindow *window);

  void handleIsRemoteComposingChanged (bool status);
  void handleMessageReceived (const std::shared_ptr<linphone::ChatMessage> &message);
  void handleMessageSent (const std::shared_ptr<linphone::ChatMessage> &message);

  int mMaxDisplayedEntries = EntriesChunkSize;

  QString mPeerAddress;
  QString mLocalAddress;

  std::shared_ptr<ChatModel> mChatModel;

  static constexpr int EntriesChunkSize = 50;
};

#endif // CHAT_PROXY_MODEL_H_
