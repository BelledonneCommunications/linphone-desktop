/*
 * TelephoneNumbersModel.hpp
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
 *  Created on: May 31, 2017
 *      Author: Ronan Abhamon
 */

#ifndef TELEPHONE_NUMBERS_MODEL_H_
#define TELEPHONE_NUMBERS_MODEL_H_

#include <QAbstractListModel>
#include <QLocale>

// =============================================================================

class TelephoneNumbersModel : public QAbstractListModel {
  Q_OBJECT;

  Q_PROPERTY(int defaultIndex READ getDefaultIndex CONSTANT);

public:
  TelephoneNumbersModel (QObject *parent = Q_NULLPTR);
  ~TelephoneNumbersModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

private:
  int getDefaultIndex () const;

  static const QList<QPair<QLocale::Country, QString> > mCountryCodes;
};

#endif // ifndef TELEPHONE_NUMBERS_MODEL_H_
