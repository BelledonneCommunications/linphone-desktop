/*
 * ConferenceHelperModel.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
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
 *  Created on: May 11, 2017
 *      Author: Ronan Abhamon
 */

#include <QSortFilterProxyModel>

// =============================================================================

class CallModel;

class ConferenceHelperModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(QStringList inConference READ getInConference NOTIFY inConferenceChanged);

public:
  ConferenceHelperModel (QObject *parent = Q_NULLPTR);
  ~ConferenceHelperModel () = default;

  QHash<int, QByteArray> roleNames () const override;

  Q_INVOKABLE void setFilter (const QString &pattern);

signals:
  void inConferenceChanged (const QStringList &inConference);

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;

private:
  void handleCallRunning (int index, CallModel *callModel);
  void handleCallsAboutToBeRemoved (const QModelIndex &parent, int first, int last);

  bool addToConference (const QString &sipAddress);
  bool removeFromConference (const QString &sipAddress);

  QStringList getInConference () {
    return mInConference;
  }

  QStringList mInConference;
  QStringList mToAdd;
};
