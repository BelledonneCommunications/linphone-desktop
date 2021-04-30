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

#ifndef TIMELINE_PROXY_MODEL_H_
#define TIMELINE_PROXY_MODEL_H_

#include <QSortFilterProxyModel>
// =============================================================================

#include "../chat/ChatModel.hpp"

class TimelineModel;

class TimelineProxyModel : public QSortFilterProxyModel {
  Q_OBJECT


public:
  TimelineProxyModel (QObject *parent = Q_NULLPTR);
  
  Q_PROPERTY(std::shared_ptr<ChatModel> currentChatModel WRITE setCurrentChatModel READ getCurrentChatModel NOTIFY currentChatModelChanged)
  
  void updateCurrentSelection();
  
  Q_INVOKABLE void setCurrentChatModel(std::shared_ptr<ChatModel> data);
  std::shared_ptr<ChatModel> getCurrentChatModel() const;
    
signals:
  void currentChatModelChanged(std::shared_ptr<ChatModel> currentChatModel);
  void currentTimelineChanged(TimelineModel * currentTimeline);
  

protected:

  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;

  QString getLocalAddress () const;
  QString getCleanedLocalAddress () const;
  void handleLocalAddressChanged (const QString &localAddress);
  
  
  std::shared_ptr<ChatModel> mCurrentChatModel;

};

#endif // TIMELINE_PROXY_MODEL_H_
