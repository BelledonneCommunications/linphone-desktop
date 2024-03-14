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

#include "TimeZone.hpp"

#include "core/App.hpp"

#include <QQmlApplicationEngine>

// =============================================================================

TimeZoneModel::TimeZoneModel(const QTimeZone &timeZone, QObject *parent) : QObject(parent) {
	App::getInstance()->mEngine->setObjectOwnership(
	    this, QQmlEngine::CppOwnership); // Avoid QML to destroy it when passing by Q_INVOKABLE
	mTimeZone = timeZone;
}

TimeZoneModel::~TimeZoneModel() {
}

QTimeZone TimeZoneModel::getTimeZone() const {
	return mTimeZone;
}

int TimeZoneModel::getOffsetFromUtc() const {
	return mTimeZone.offsetFromUtc(QDateTime::currentDateTime());
}

int TimeZoneModel::getStandardTimeOffset() const {
	return mTimeZone.standardTimeOffset(QDateTime::currentDateTime());
}

QString TimeZoneModel::getCountryName() const {
	return QLocale::territoryToString(mTimeZone.territory());
}

QString TimeZoneModel::getDisplayName() const {
	return mTimeZone.displayName(QTimeZone::TimeType::GenericTime, QTimeZone::NameType::LongName);
}
