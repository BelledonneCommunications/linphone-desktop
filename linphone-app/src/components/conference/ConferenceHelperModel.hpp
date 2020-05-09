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

#ifndef CONFERENCE_HELPER_MODEL_H_
#define CONFERENCE_HELPER_MODEL_H_

#include <memory>

#include <QSortFilterProxyModel>

// =============================================================================
// Sip addresses not in conference.
// Can filter the sip addresses with a pattern.
// =============================================================================

namespace linphone {
  class Conference;
  class Core;
}

class CallModel;

class ConferenceHelperModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(ConferenceHelperModel::ConferenceAddModel *toAdd READ getConferenceAddModel CONSTANT);

public:
  class ConferenceAddModel;

  ConferenceHelperModel (QObject *parent = Q_NULLPTR);

  QHash<int, QByteArray> roleNames () const override;

  ConferenceAddModel *getConferenceAddModel () const {
    return mConferenceAddModel;
  }

  Q_INVOKABLE void setFilter (const QString &pattern);

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;

private:

  ConferenceAddModel *mConferenceAddModel = nullptr;

  std::shared_ptr<linphone::Core> mCore;
};

#endif // CONFERENCE_HELPER_MODEL_H_
