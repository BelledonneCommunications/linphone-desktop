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

#include "TimeZoneList.hpp"
#include "core/App.hpp"

#include <QFuture>
#include <QTimeZone>
#include <QtConcurrent>
#include <set>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(TimeZoneList)

using namespace std;

QSharedPointer<TimeZoneList> TimeZoneList::create() {
	auto model = QSharedPointer<TimeZoneList>(new TimeZoneList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	return model;
}

TimeZoneList::TimeZoneList(QObject *parent) : ListProxy(parent) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// There is too much items (more than 400) to be sort in main thread. Dispatch the process.
	QFuture<void> future = QtConcurrent::run([this]() { initTimeZones(); });
}

TimeZoneList::~TimeZoneList() {
	mustBeInMainThread("~" + getClassName());
}
// -----------------------------------------------------------------------------

void TimeZoneList::initTimeZones() {
	QList<QSharedPointer<QObject>> models;
	QElapsedTimer benchmark;
	benchmark.start();
	for (auto id : QTimeZone::availableTimeZoneIds()) {
		auto model = QSharedPointer<TimeZoneModel>::create(QTimeZone(id));
		if (std::find_if(mList.begin(), mList.end(), [id](const QSharedPointer<QObject> &a) {
			    return a.objectCast<TimeZoneModel>()->getTimeZone() == QTimeZone(id);
		    }) == mList.end()) {
			if (model->getCountryName().toUpper() != "DEFAULT") {
				models << model;
			}
		}
	}
	std::sort(models.begin(), models.end(), [](QSharedPointer<QObject> a, QSharedPointer<QObject> b) {
		auto tA = a.objectCast<TimeZoneModel>();
		auto tB = b.objectCast<TimeZoneModel>();
		auto timeA = tA->getStandardTimeOffset() / 3600;
		auto timeB = tB->getStandardTimeOffset() / 3600;
		return timeA < timeB || (timeA == timeB && tA->getCountryName() < tB->getCountryName());
	});
	lDebug() << log().arg("Sorting %1 TZ : %2ms").arg(models.size()).arg(benchmark.elapsed());
	// Reset models inside main thread.
	QMetaObject::invokeMethod(this, [this, models]() { resetData(models); });
}

QHash<int, QByteArray> TimeZoneList::roleNames() const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	roles[Qt::DisplayRole + 1] = "$timeZoneModel";
	return roles;
}

QVariant TimeZoneList::data(const QModelIndex &index, int role) const {
	int row = index.row();

	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	auto timeZoneModel = getAt<TimeZoneModel>(row);
	if (!timeZoneModel) return QVariant();
	if (role == Qt::DisplayRole + 1) {
		return QVariant::fromValue(timeZoneModel.get());
	} else {
		int offset = timeZoneModel->getStandardTimeOffset() / 3600;
		int absOffset = std::abs(offset);
		return QStringLiteral("(GMT%1%2%3:00) %4 %5")
		    .arg(offset >= 0 ? "+" : "-")
		    .arg(absOffset < 10 ? "0" : "")
		    .arg(absOffset)
		    .arg(timeZoneModel->getCountryName())
		    .arg(timeZoneModel->getTimeZone().comment().isEmpty() ? ""
		                                                          : (" - " + timeZoneModel->getTimeZone().comment()));
	}
}

int TimeZoneList::get(const QTimeZone &timeZone) const {
	auto it = find_if(mList.cbegin(), mList.cend(), [&timeZone](QSharedPointer<QObject> item) {
		return item.objectCast<TimeZoneModel>()->getTimeZone() == timeZone;
	});
	if (it == mList.cend()) {
		auto today = QDateTime::currentDateTime();
		it = find_if(mList.cbegin(), mList.cend(), [&timeZone, today](QSharedPointer<QObject> item) {
			auto tz = item.objectCast<TimeZoneModel>()->getTimeZone();
			return (timeZone.territory() == QLocale::AnyCountry || tz.territory() == timeZone.territory()) &&
			       tz.standardTimeOffset(today) == timeZone.standardTimeOffset(today);
		});
	}
	return it != mList.cend() ? int(distance(mList.cbegin(), it)) : 0;
}
