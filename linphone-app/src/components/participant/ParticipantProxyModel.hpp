/*
 * Copyright (c) 2020 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_PROXY_MODEL_H_
#define PARTICIPANT_PROXY_MODEL_H_

#include <QSortFilterProxyModel>
#include <memory>

class ParticipantModel;
class ChatRoomModel;
class ParticipantListModel;
// =============================================================================

class QWindow;

class ParticipantProxyModel : public QSortFilterProxyModel {

  Q_OBJECT


public:
  ParticipantProxyModel ( QObject *parent = Q_NULLPTR);
  
  Q_PROPERTY(ChatRoomModel* chatRoomModel READ getChatRoomModel WRITE setChatRoomModel NOTIFY chatRoomModelChanged)
  Q_PROPERTY(int count READ getCount NOTIFY countChanged)

  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
  
  ChatRoomModel *getChatRoomModel() const;
  Q_INVOKABLE QStringList getSipAddresses() const;
  Q_INVOKABLE QVariantList getParticipants() const;
  Q_INVOKABLE int getCount() const;
  
  void setChatRoomModel(ChatRoomModel * chatRoomModel);
  
  Q_INVOKABLE void add(const QString& address);
  Q_INVOKABLE void remove(ParticipantModel * participant);
  
  
  
signals:
  void chatRoomModelChanged();
  void countChanged();
  
private:
  /*
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;*/

  //std::shared_ptr<ParticipantListModel> mParticipantListModel;
  ChatRoomModel *mChatRoomModel;
};

#endif // PARTICIPANT_PROXY_MODEL_H_
