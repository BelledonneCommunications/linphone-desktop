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

#ifndef CONFERENCE_ADD_MODEL_H_
#define CONFERENCE_ADD_MODEL_H_

#include "ConferenceHelperModel.hpp"

// =============================================================================
// Sip addresses list to add to conference.
// =============================================================================

namespace linphone {
  class Address;
}

class ConferenceHelperModel::ConferenceAddModel : public QAbstractListModel {
  Q_OBJECT;

public:
  ConferenceAddModel (QObject *parent = Q_NULLPTR);

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  bool addToConference (const std::shared_ptr<const linphone::Address> &linphoneAddress);

  Q_INVOKABLE bool addToConference (const QString &sipAddress);
  Q_INVOKABLE bool removeFromConference (const QString &sipAddress);

  Q_INVOKABLE void update ();

  bool contains (const QString &sipAddress) const {
    return mSipAddresses.contains(sipAddress);
  }

private:
  void addToConferencePrivate (const std::shared_ptr<linphone::Address> &linphoneAddress);

  void handleDataChanged (
    const QModelIndex &topLeft,
    const QModelIndex &bottomRight,
    const QVector<int> &roles = QVector<int>()
  );

  QHash<QString, QVariantMap> mSipAddresses;
  QList<const QVariantMap *> mRefs;

  ConferenceHelperModel *mConferenceHelperModel = nullptr;
};

Q_DECLARE_METATYPE(std::shared_ptr<linphone::Address>);

#endif // CONFERENCE_ADD_MODEL_H_
