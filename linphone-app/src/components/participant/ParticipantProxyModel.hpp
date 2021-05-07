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

#include "ParticipantModel.hpp"

// =============================================================================

class QWindow;

class ParticipantProxyModel : public QSortFilterProxyModel {

  Q_OBJECT


public:
  ParticipantProxyModel (QObject *parent = Q_NULLPTR);
  
  void reset();
  void update();
  std::shared_ptr<TimelineModel> getTimeline(std::shared_ptr<linphone::ChatRoom> chatRoom, const bool &create);

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

// Remove a chatroom
  Q_INVOKABLE void remove (TimelineModel *importer);

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
  
  
  
  void initTimeline ();
  void updateTimelines();

  QList<std::shared_ptr<ParticipantModel>> mParticipantlines;
};

#endif // PARTICIPANT_PROXY_MODEL_H_
