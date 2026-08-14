/*
 * Copyright (c) 2010-2026 Belledonne Communications SARL.
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

#ifndef RECORDING_PROXY_H_
#define RECORDING_PROXY_H_

#include "../proxy/LimitProxy.hpp"
#include "../proxy/SortFilterProxy.hpp"
#include "RecordingList.hpp"
#include "tool/AbstractObject.hpp"

class RecordingProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(bool loading READ getLoading NOTIFY loadingChanged)

public:
	DECLARE_SORTFILTER_CLASS()

	RecordingProxy(QObject *parent = Q_NULLPTR);
	~RecordingProxy();

	bool getLoading() const;

	Q_INVOKABLE void reload();
	Q_INVOKABLE void removeAll();

signals:
	void listAboutToBeReset();
	void loadingChanged();

protected:
	bool mLoading = true;
	QSharedPointer<RecordingList> mRecordingList;

	DECLARE_ABSTRACT_OBJECT
};

#endif
