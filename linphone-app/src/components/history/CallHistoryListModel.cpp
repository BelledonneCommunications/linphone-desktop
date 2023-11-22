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

#include "CallHistoryListModel.hpp"
#include "CallHistoryModel.hpp"

#include "components/core/CoreManager.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/settings/AccountSettingsModel.hpp"
#include "utils/Utils.hpp"

// =============================================================================

CallHistoryListModel::CallHistoryListModel (QObject *parent) : ProxyListModel(parent) {
	reload();
	connect(CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::callLogUpdated, this, &CallHistoryListModel::onCallLogUpdated);
}

QString reorder(const QString& address){
	QStringList splitted = address.split(";");
	QString newAddress = splitted[0];
	splitted.removeFirst();
	splitted.sort();
	return newAddress + splitted.join(";");
}

void CallHistoryListModel::reload() {
	beginResetModel();
	mList.clear();
	endResetModel();
	auto account = CoreManager::getInstance()->getCore()->getDefaultAccount();
	auto callLogs = account ? account->getCallLogs() : CoreManager::getInstance()->getCore()->getCallLogs();
	add(callLogs);
	CoreManager::getInstance()->resetMissedCallsCount();
	if(mList.size() > 0)
		QTimer::singleShot(1, [&](){
			mList.at(0).objectCast<CallHistoryModel>()->selectOnly();
		});
}

CallHistoryListModel::~CallHistoryListModel(){
}

void CallHistoryListModel::add(const std::list<std::shared_ptr<linphone::CallLog>>& callLogs){
	QList<QSharedPointer<CallHistoryModel>> toAdd;
	auto defaultAccount = CoreManager::getInstance()->getCore()->getDefaultAccount();
	for(auto callLog : callLogs) {
		if(defaultAccount && !callLog->getLocalAddress()->weakEqual(CoreManager::getInstance()->getAccountSettingsModel()->getUsedSipAddress()))
			continue;
		QString confUri;
		auto remoteAddress = callLog->getRemoteAddress()->clone();
		remoteAddress->clean();
		QString address = reorder(Utils::coreStringToAppString(remoteAddress->asStringUriOnly()));
		if( callLog->getConferenceInfo()) {
			confUri = reorder(Utils::coreStringToAppString(callLog->getConferenceInfo()->getUri()->asStringUriOnly()));
		}
		QString keyName = address + "/"+confUri;
		if(!mCalls.contains(keyName)) {
			auto call = QSharedPointer<CallHistoryModel>::create(callLog);
			mCalls[keyName] = call;
			connect(call.get(), &CallHistoryModel::selectOnlyRequested, this, &CallHistoryListModel::onSelectOnlyRequested);
			connect(call.get(), &CallHistoryModel::selectedChanged, this, &CallHistoryListModel::onSelectedChanged);
			connect(call.get(), &CallHistoryModel::hasBeenRemoved, this, &CallHistoryListModel::onHasBeenRemoved);
			connect(call.get(), &CallHistoryModel::lastCallDateChanged, this, &CallHistoryListModel::lastCallDateChanged);
			toAdd << call;
		}else{
			mCalls[keyName]->update(callLog);
		}
	}
	
	ProxyListModel::add(toAdd);
}

void CallHistoryListModel::onCallLogUpdated(const std::shared_ptr<linphone::CallLog> &call){
	add(std::list<std::shared_ptr<linphone::CallLog>>{call});
}

void CallHistoryListModel::onSelectOnlyRequested() {
	for(auto model : mList){
		auto callModel = model.objectCast<CallHistoryModel>();
		if(callModel != sender())
			callModel->setSelected(false);
	}
}

void CallHistoryListModel::onSelectedChanged(bool selected, CallHistoryModel * model) {
	if(selected) {
		emit selectedChanged(model);
		CoreManager::getInstance()->resetMissedCallsCount();
	}
}
void CallHistoryListModel::onHasBeenRemoved(){
	QString confUri;
	auto model = qobject_cast<CallHistoryModel*>(sender());
	QString address = reorder(model->getRemoteAddress());
	if( model->wasConference()) {
		confUri = reorder(Utils::coreStringToAppString(model->getConferenceInfoModel()->getConferenceInfo()->getUri()->asStringUriOnly()));
	}
	remove(sender());
	QString keyName = address + "/"+confUri;
	mCalls.remove(keyName);
	if(model->mSelected) {
		if(mList.size() > 0){
			mList.at(0).objectCast<CallHistoryModel>()->selectOnly();
		}
	}
}
