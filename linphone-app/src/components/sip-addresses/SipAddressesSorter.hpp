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

#ifndef SIP_ADDRESSES_SORTER_H_
#define SIP_ADDRESSES_SORTER_H_

#include <QObject>
#include <QString>
#include <QVariantMap>

// =============================================================================

class SipAddressesSorter : public QObject{
	Q_OBJECT
	
public:
	SipAddressesSorter (QObject *parent = Q_NULLPTR);
	
	static bool lessThan( const QString& filter, const QVariantMap &left, const QVariantMap &right);
	
private:
	static int computeEntryWeight (const QString& filter, const QVariantMap &entry);
	static int computeStringWeight (const QString& filter, const QString &string);
	
	static const QRegExp SearchSeparators;
};

#endif
