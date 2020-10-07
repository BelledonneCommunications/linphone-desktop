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

#include <QQuickWindow>

#include "app/App.hpp"
#include "components/core/CoreManager.hpp"

#include "HistoryProxyModel.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"

// =============================================================================

using namespace std;

// Fetch the L last filtered history entries.
class HistoryProxyModel::HistoryModelFilter : public QSortFilterProxyModel {
public:
	HistoryModelFilter (QObject *parent) : QSortFilterProxyModel(parent) { }
	
	HistoryModel::EntryType getEntryTypeFilter () {
		return mEntryTypeFilter;
	}
	
	void setEntryTypeFilter (HistoryModel::EntryType type) {
		mEntryTypeFilter = type;
		invalidate();
	}
	
protected:
	bool filterAcceptsRow (int sourceRow, const QModelIndex &) const override {
		if (mEntryTypeFilter == HistoryModel::EntryType::GenericEntry)
			return true;
		
		QModelIndex index = sourceModel()->index(sourceRow, 0, QModelIndex());
		const QVariantMap data = index.data().toMap();
		
		return data["type"].toInt() == mEntryTypeFilter;
	}
	
private:
	HistoryModel::EntryType mEntryTypeFilter = HistoryModel::EntryType::GenericEntry;
};

// =============================================================================

HistoryProxyModel::HistoryProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	
	setSourceModel(new HistoryModelFilter(this));
	reload();
	
	App *app = App::getInstance();
	QObject::connect(app->getMainWindow(), &QWindow::activeChanged, this, [this]() {
		handleIsActiveChanged(App::getInstance()->getMainWindow());
	});
	
	QQuickWindow *callsWindow = app->getCallsWindow();
	if (callsWindow)
		QObject::connect(callsWindow, &QWindow::activeChanged, this, [this, callsWindow]() {
			handleIsActiveChanged(callsWindow);
		});
}

// -----------------------------------------------------------------------------

void HistoryProxyModel::removeAllEntries(){
	auto model = CoreManager::getInstance()->getHistoryModel();
	if (!model)
		return;
	model->removeAllEntries();
}
void HistoryProxyModel::removeEntry (int id){
	auto model = CoreManager::getInstance()->getHistoryModel();
	if (!model)
		return;
	QModelIndex sourceIndex = mapToSource(index(id, 0));
	model->removeEntry(static_cast<HistoryModelFilter *>(sourceModel())->mapToSource(sourceIndex).row() );
}
// -----------------------------------------------------------------------------

void HistoryProxyModel::loadMoreEntries () {
	int count = rowCount();
	int parentCount = sourceModel()->rowCount();
	
	if (count < parentCount) {
		// Do not increase `mMaxDisplayedEntries` if it's not necessary...
		// Limit qml calls.
		if (count == mMaxDisplayedEntries)
			mMaxDisplayedEntries += EntriesChunkSize;
		
		invalidateFilter();
		
		count = rowCount() - count;
		if (count > 0)
			emit moreEntriesLoaded(count);
	}
}

void HistoryProxyModel::setEntryTypeFilter (HistoryModel::EntryType type) {
	HistoryModelFilter *HistoryModelFilter = static_cast<HistoryProxyModel::HistoryModelFilter *>(sourceModel());
	
	if (HistoryModelFilter->getEntryTypeFilter() != type) {
		HistoryModelFilter->setEntryTypeFilter(type);
		emit entryTypeFilterChanged(type);
	}
}

// -----------------------------------------------------------------------------

bool HistoryProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &) const {
	return sourceModel()->rowCount() - sourceRow <= mMaxDisplayedEntries;
}

// -----------------------------------------------------------------------------

void HistoryProxyModel::reload () {
	mMaxDisplayedEntries = EntriesChunkSize;
	static_cast<HistoryModelFilter *>(sourceModel())->setSourceModel(CoreManager::getInstance()->getHistoryModel());
}
void HistoryProxyModel::resetMessageCount(){
	auto model = CoreManager::getInstance()->getHistoryModel();
	if( model){
		model->resetMessageCount();
	}
}
// -----------------------------------------------------------------------------

static inline QWindow *getParentWindow (QObject *object) {
	App *app = App::getInstance();
	const QWindow *mainWindow = app->getMainWindow();
	const QWindow *callsWindow = app->getCallsWindow();
	for (QObject *parent = object->parent(); parent; parent = parent->parent())
		if (parent == mainWindow || parent == callsWindow)
			return static_cast<QWindow *>(parent);
	return nullptr;
}

void HistoryProxyModel::handleIsActiveChanged (QWindow *window) {
	auto model = CoreManager::getInstance()->getHistoryModel();
	if (model && window->isActive() && getParentWindow(this) == window) {
		model->focused();
		model->resetMessageCount();
	}
}
