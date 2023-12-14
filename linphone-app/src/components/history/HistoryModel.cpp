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

#include <algorithm>

#include <QDateTime>
#include <QDesktopServices>
#include <QElapsedTimer>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QTimer>
#include <QUuid>
#include <QMessageBox>
#include <QUrlQuery>
#include <QImageReader>

#include "CallHistoryModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "utils/Utils.hpp"

#include "HistoryModel.hpp"

// =============================================================================

using namespace std;

static inline void fillCallStartEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
	dest["type"] = HistoryModel::CallEntry;
	dest["timestamp"] = QDateTime::fromMSecsSinceEpoch(callLog->getStartDate() * 1000);
	dest["receivedTimestamp"] = dest["timestamp"];
	dest["isOutgoing"] = callLog->getDir() == linphone::Call::Dir::Outgoing;
	dest["status"] = static_cast<HistoryModel::CallStatus>(callLog->getStatus());
	dest["isStart"] = true;
	if(callLog->getConferenceInfo()){
		dest["title"] = Utils::coreStringToAppString(callLog->getConferenceInfo()->getSubject());
		dest["sipAddress"] = Utils::coreStringToAppString(callLog->getConferenceInfo()->getUri()->asString());
	}else
		dest["sipAddress"] = Utils::coreStringToAppString(callLog->getRemoteAddress()->asString());
	dest["callId"] = Utils::coreStringToAppString(callLog->getCallId());
	dest["wasConference"] = callLog->wasConference();
}

static inline void fillCallEndEntry (QVariantMap &dest, const shared_ptr<linphone::CallLog> &callLog) {
	dest["type"] = HistoryModel::CallEntry;
	dest["timestamp"] = QDateTime::fromMSecsSinceEpoch((callLog->getStartDate() + callLog->getDuration()) * 1000);
	dest["receivedTimestamp"] = dest["timestamp"];
	dest["isOutgoing"] = callLog->getDir() == linphone::Call::Dir::Outgoing;
	dest["status"] = static_cast<HistoryModel::CallStatus>(callLog->getStatus());
	dest["isStart"] = false;
	if(callLog->getConferenceInfo()){
		dest["title"] = Utils::coreStringToAppString(callLog->getConferenceInfo()->getSubject());
		dest["sipAddress"] = Utils::coreStringToAppString(callLog->getConferenceInfo()->getUri()->asString());
	}else
		dest["sipAddress"] = Utils::coreStringToAppString(callLog->getRemoteAddress()->asString());
	dest["callId"] = Utils::coreStringToAppString(callLog->getCallId());
	dest["wasConference"] = callLog->wasConference();
}

// -----------------------------------------------------------------------------

HistoryModel::HistoryModel (QObject *parent) :QAbstractListModel(parent){
	CoreManager *coreManager = CoreManager::getInstance();
	
	mCoreHandlers = coreManager->getHandlers();
	
	setSipAddresses();
	CoreHandlers *coreHandlers = mCoreHandlers.get();
	QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &HistoryModel::handleCallStateChanged);
}

HistoryModel::HistoryModel (CallHistoryModel * callHistoryModel, QObject *parent) :QAbstractListModel(parent){
	CoreManager *coreManager = CoreManager::getInstance();
	
	mCoreHandlers = coreManager->getHandlers();
	setSipAddresses(callHistoryModel);
	CoreHandlers *coreHandlers = mCoreHandlers.get();
	QObject::connect(coreHandlers, &CoreHandlers::callStateChanged, this, &HistoryModel::handleCallStateChanged);
}

HistoryModel::~HistoryModel () {
	qWarning() << "Destroying HistoryModel";
}

QHash<int, QByteArray> HistoryModel::roleNames () const {
	QHash<int, QByteArray> roles;
	roles[Roles::HistoryEntry] = "$historyEntry";
	roles[Roles::SectionDate] = "$sectionDate";
	return roles;
}

int HistoryModel::rowCount (const QModelIndex &) const {
	return mEntries.count();
}

QVariant HistoryModel::data (const QModelIndex &index, int role) const {
	int row = index.row();
	
	if (!index.isValid() || row < 0 || row >= mEntries.count())
		return QVariant();
	
	switch (role) {
	case Roles::HistoryEntry: {
		auto &data = mEntries[row].first;
		return QVariant::fromValue(data);
	}
	case Roles::SectionDate:{
		return QVariant::fromValue(Utils::toDateString(mEntries[row].first["receivedTimestamp"].toDateTime()));
	}
	}
	
	return QVariant();
}

bool HistoryModel::removeRow (int row, const QModelIndex &) {
	return removeRows(row, 1);
}

bool HistoryModel::removeRows (int row, int count, const QModelIndex &parent) {
	int limit = row + count - 1;
	
	if (row < 0 || count < 0 || limit >= mEntries.count())
		return false;
	emit layoutAboutToBeChanged();
	beginRemoveRows(parent, row, limit);
	
	for (int i = 0; i < count; ++i) {
		removeEntry(mEntries[row]);
		mEntries.removeAt(row);
	}
	
	endRemoveRows();
	
	if (mEntries.count() == 0)
		emit allEntriesRemoved();
	else if (limit == mEntries.count())
		emit lastEntryRemoved();
	emit CoreManager::getInstance()->callLogsCountChanged();
	emit focused();// Removing rows is like having focus. Don't wait asynchronous events.
	emit layoutChanged();
	return true;
}

static bool hasSameParameters(const QStringList& a, const QStringList& b){
	if(a.size() != b.size())
		return false;
	int i = 0;
	while(i < a.size()) {
		if(b.contains(a[i]))
			++i;
		else
			break;
	}
	return i >= a.size();
}
// Why complicated?
// - Address parameters can be stored in different order and getCallHistory() reorder address parameters => need to get on pure address without parameters.
// - A call to/from someone (no gruu and no conf-id) can a conference call => the pair remotre address + URI need to be check (watchout of parameters order)
void HistoryModel::setSipAddresses (CallHistoryModel *callModel) {
	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
	beginResetModel();
	mEntries.clear();
	
	QElapsedTimer timer;
	timer.start();
	
	// Get calls.
	if(!callModel)
		for (auto &callLog : core->getCallLogs())
			insertCall(callLog);
	else{
		mRemoteAddress = callModel->getRemoteAddress();
		auto address = Utils::interpretUrl(mRemoteAddress);// already cleaned
		auto conferenceInfoModel = callModel->getConferenceInfoModel();
		QStringList conferenceInfoModelParams;
		if(conferenceInfoModel) {
			mConferenceUri = conferenceInfoModel->getUri();
			conferenceInfoModelParams = mConferenceUri.split(";");
		}
		auto calls = core->getDefaultAccount() ? core->getCallHistory(address, CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress()) : core->getCallLogs();
		if (!core->getDefaultAccount()) {
			calls.remove_if([address](std::shared_ptr<linphone::CallLog> call) {
				return !call->getRemoteAddress()->weakEqual(address);
			});
		}
		for (auto &callLog : calls) {
			bool toInsert = false;
			auto callLogConferenceInfoModel = callLog->getConferenceInfo();
			if(conferenceInfoModel && callLogConferenceInfoModel) {
				QStringList logConfUriParams = Utils::coreStringToAppString(callLogConferenceInfoModel->getUri()->asStringUriOnly()).split(";");
				if(hasSameParameters(conferenceInfoModelParams, logConfUriParams)) {// Uri addresses are equal
					toInsert = true;
				}
			}else if(!conferenceInfoModel && !callLogConferenceInfoModel)
				toInsert = true;
			if(toInsert)
				insertCall(callLog);
		}
	}
	
	qInfo() << QStringLiteral("HistoryModel loaded in %3 milliseconds.").arg(timer.elapsed());
	endResetModel();
}
void HistoryModel::reload(){
	beginResetModel();
	//setSipAddresses();
	endResetModel();
}
// -----------------------------------------------------------------------------

void HistoryModel::removeEntry (int id) {
	qInfo() << QStringLiteral("Removing call entry: %1.").arg(id);
	
	if (!removeRow(id))
		qWarning() << QStringLiteral("Unable to remove call entry: %1").arg(id);
}

void HistoryModel::removeAllEntries () {
	qInfo() << QStringLiteral("Removing all call entries.");
	
	beginResetModel();
	
	for (auto &entry : mEntries)
		removeEntry(entry);
	
	mEntries.clear();
	
	endResetModel();
	
	emit allEntriesRemoved();
	emit CoreManager::getInstance()->callLogsCountChanged();
	emit focused();// Removing all entries is like having focus. Don't wait asynchronous events.
}

// -----------------------------------------------------------------------------

void HistoryModel::removeEntry (HistoryEntryData &entry) {
	int type = entry.first["type"].toInt();
	
	switch (type) {
		
	case HistoryModel::CallEntry: {
		if (entry.first["status"].toInt() == CallStatusSuccess) {
			// WARNING: Unable to remove symmetric call here. (start/end)
			// We are between `beginRemoveRows` and `endRemoveRows`.
			// A solution is to schedule a `removeEntry` call in the Qt main loop.
			shared_ptr<void> linphonePtr = entry.second;
			QTimer::singleShot(0, this, [this, linphonePtr]() {
				auto it = find_if(mEntries.begin(), mEntries.end(), [linphonePtr](const HistoryEntryData &entry) {
					return entry.second == linphonePtr;
				});
				
				if (it != mEntries.end())
					removeEntry(int(distance(mEntries.begin(), it)));
			});
		}
		
		CoreManager::getInstance()->getCore()->removeCallLog(static_pointer_cast<linphone::CallLog>(entry.second));
		break;
	}
		
	default:
		qWarning() << QStringLiteral("Unknown history entry type: %1.").arg(type);
	}
}

void HistoryModel::insertCall (const shared_ptr<linphone::CallLog> &callLog) {
	linphone::Call::Status status = callLog->getStatus();
	
	auto insertEntry = [this](
	const HistoryEntryData &entry,
	const QList<HistoryEntryData>::iterator *start = nullptr
	) {
		auto it = lower_bound(start ? *start : mEntries.begin(), mEntries.end(), entry, [](const HistoryEntryData &a, const HistoryEntryData &b) {
			return a.first["receivedTimestamp"] < b.first["receivedTimestamp"];
		});
		
		int row = int(distance(mEntries.begin(), it));
		emit layoutAboutToBeChanged();
		beginInsertRows(QModelIndex(), row, row);
		it = mEntries.insert(it, entry);
		endInsertRows();
		emit layoutChanged();
		
		return it;
	};
	
	// Add start call.
	QVariantMap start;
	fillCallStartEntry(start, callLog);
	auto it = insertEntry(qMakePair(start, static_pointer_cast<void>(callLog)));
	
	if (status == linphone::Call::Status::Success) {
		QVariantMap end;
		fillCallEndEntry(end, callLog);
		insertEntry(qMakePair(end, static_pointer_cast<void>(callLog)), &it);
	}
}

// -----------------------------------------------------------------------------

void HistoryModel::resetMessageCount () {
	emit callCountReset();
}

// -----------------------------------------------------------------------------

void HistoryModel::handleCallStateChanged (const shared_ptr<linphone::Call> &call, linphone::Call::State state) {
	if (state == linphone::Call::State::End || state == linphone::Call::State::Error) {
		auto address = Utils::interpretUrl(mRemoteAddress);// already cleaned
		QStringList conferenceInfoModelParams = mConferenceUri.split(";");
		bool toInsert = false;
		auto callLog = call->getCallLog();
		auto callLogConferenceInfoModel = callLog->getConferenceInfo();
		if(mRemoteAddress.isEmpty())
			toInsert = true;
		else if(address->weakEqual(callLog->getRemoteAddress()) 
				&& (!CoreManager::getInstance()->getCore()->getDefaultAccount() || callLog->getLocalAddress()->weakEqual(CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress()))) {
			if(!mConferenceUri.isEmpty() && callLogConferenceInfoModel) {
				QStringList logConfUriParams = Utils::coreStringToAppString(callLogConferenceInfoModel->getUri()->asStringUriOnly()).split(";");
				if(hasSameParameters(conferenceInfoModelParams, logConfUriParams)) {// Uri addresses are equal
					toInsert = true;
				}
			}else if(mConferenceUri.isEmpty() && !callLogConferenceInfoModel)
				toInsert = true;
		}
		if(toInsert)
			insertCall(callLog);
	}
}

