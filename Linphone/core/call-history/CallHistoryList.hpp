/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef CALL_HISTORY_LIST_H_
#define CALL_HISTORY_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class CallGui;
class CallHistoryCore;
class CoreModel;
// =============================================================================

class CallHistoryList : public ListProxy, public AbstractObject {
	Q_OBJECT
public:
	static QSharedPointer<CallHistoryList> create();
	// Create a CallHistoryCore and make connections to List.
	QSharedPointer<CallHistoryCore> createCallHistoryCore(const std::shared_ptr<linphone::CallLog> &callLog);
	CallHistoryList(QObject *parent = Q_NULLPTR);
	~CallHistoryList();

	void setSelf(QSharedPointer<CallHistoryList> me);
	void toConnect(CallHistoryCore *data);

	void removeAllEntries();
	void removeEntriesWithFilter(QString filter);
	void remove(const int &row);

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

	// virtual QHash<int, QByteArray> roleNames() const override {
	// 	QHash<int, QByteArray> roles;
	// 	roles[Qt::DisplayRole] = "gui";
	// 	roles[Qt::DisplayRole + 1] = "name";
	// 	roles[Qt::DisplayRole + 2] = "date";
	// 	return roles;
	// }
	// void displayMore();

signals:
	void lUpdate();
	void lRemoveEntriesForAddress(QString address);
	void lRemoveAllEntries();

private:
	// Check the state from CallHistoryCore: sender() must be a CallHistoryCore.
	void onStatusChanged();

	bool mHaveCallHistory = false;
	QSharedPointer<SafeConnection<CallHistoryList, CoreModel>> mModelConnection;
	DECLARE_ABSTRACT_OBJECT
};

#endif
