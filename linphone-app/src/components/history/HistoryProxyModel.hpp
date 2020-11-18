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

#ifndef HISTORY_PROXY_MODEL_H_
#define HISTORY_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "HistoryModel.hpp"

// =============================================================================

class QWindow;

class HistoryProxyModel : public QSortFilterProxyModel {
	class HistoryModelFilter;
	
	Q_OBJECT;
	
public:
	HistoryProxyModel (QObject *parent = Q_NULLPTR);
	
	Q_INVOKABLE void loadMoreEntries ();
	Q_INVOKABLE void setEntryTypeFilter (HistoryModel::EntryType type = HistoryModel::EntryType::CallEntry);
	Q_INVOKABLE void removeEntry (int id);
	
	Q_INVOKABLE void removeAllEntries ();
	
	Q_INVOKABLE void resetMessageCount();
	
signals:
	
	void moreEntriesLoaded (int n);
	
	void entryTypeFilterChanged (HistoryModel::EntryType type);
	
protected:
	bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	
private:
	
	void reload ();
	
	void handleIsActiveChanged (QWindow *window);

	int mMaxDisplayedEntries = EntriesChunkSize;
	
	static constexpr int EntriesChunkSize = 50;
};

#endif // HISTORY_PROXY_MODEL_H_
