/*
 * Copyright (c) 2020-2023 Belledonne Communications SARL.
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

#ifndef CALL_HISTORY_PROXY_MODEL_H_
#define CALL_HISTORY_PROXY_MODEL_H_

#include <QSortFilterProxyModel>
#include <memory>

class CallHistoryModel;
class QWindow;

// =============================================================================

class CallHistoryProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
public:
	CallHistoryProxyModel (QObject *parent = Q_NULLPTR);
	
	enum CallTimelineFilter {
		Incoming = 1,
		Outgoing = 2,
		Missed = 4,
		All = 0
	};
	Q_ENUM(CallTimelineFilter)
	
	Q_PROPERTY(int filterFlags MEMBER mFilterFlags WRITE setFilterFlags NOTIFY filterFlagsChanged)
	Q_PROPERTY(QString filterText MEMBER mFilterText WRITE setFilterText NOTIFY filterTextChanged)
	Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
	
	void setFilterFlags(int flags);
	Q_INVOKABLE void setFilterText(const QString& text);
	
	void handleIsActiveChanged (QWindow *window);
	
signals:
	void countChanged();
	void filterTextChanged();
	void selectedChanged(const QString& remoteAddress);
	void filterFlagsChanged();
	
protected:
	
	bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
private:
	QString mFilterText;
	int mFilterFlags = -1;
};

#endif
