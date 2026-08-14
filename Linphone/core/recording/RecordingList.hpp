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

#ifndef RECORDING_LIST_H_
#define RECORDING_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"

#include <QFileSystemWatcher>
#include <QTimer>

class CoreModel;
class RecordingCore;

class RecordingList : public ListProxy, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<RecordingList> create();
	RecordingList(QObject *parent = Q_NULLPTR);
	~RecordingList();

	void setSelf(QSharedPointer<RecordingList> me);
	void toConnect(RecordingCore *recording);

	void removeAll();

	virtual QHash<int, QByteArray> roleNames() const override;
	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void lUpdate();
	void listAboutToBeReset();
	void loadingChanged(bool loading);

private:
	void watchFolder(const QString &folder);

	QString mFolder;
	QFileSystemWatcher mWatcher;
	QTimer mReloadTimer;
	QTimer mRetryTimer;
	int mRetryCount = 0;
	QSharedPointer<SafeConnection<RecordingList, CoreModel>> mModelConnection;

	DECLARE_ABSTRACT_OBJECT
};

#endif
