/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#ifndef TIME_ZONE_MODEL_H_
#define TIME_ZONE_MODEL_H_

#include <QObject>
#include <QTimeZone>

#include <linphone++/linphone.hh>

// =============================================================================

class TimeZoneModel : public QObject {
	Q_OBJECT
	Q_PROPERTY(QTimeZone timezone MEMBER mTimeZone CONSTANT)
	Q_PROPERTY(int offsetFromUtc READ getOffsetFromUtc CONSTANT)
	Q_PROPERTY(int standardTimeOffset READ getStandardTimeOffset CONSTANT)
	Q_PROPERTY(QString countryName READ getCountryName CONSTANT)
	Q_PROPERTY(QString displayName READ getDisplayName CONSTANT)

public:
	TimeZoneModel(const QTimeZone &timeZone, QObject *parent = nullptr);
	virtual ~TimeZoneModel();

	QTimeZone getTimeZone() const;
	int getOffsetFromUtc() const;
	int getStandardTimeOffset() const;
	QString getCountryName() const;
	QString getDisplayName() const;

private:
	QTimeZone mTimeZone;
};
Q_DECLARE_METATYPE(TimeZoneModel *);
#endif
