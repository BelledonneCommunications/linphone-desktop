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

#include "CallHistoryList.hpp"
#include "CallHistoryGui.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(CallHistoryList)

QSharedPointer<CallHistoryList> CallHistoryList::create() {
	auto model = QSharedPointer<CallHistoryList>(new CallHistoryList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

QSharedPointer<CallHistoryCore>
CallHistoryList::createCallHistoryCore(const std::shared_ptr<linphone::CallLog> &callLog) {
	auto callHistoryCore = CallHistoryCore::create(callLog);
	return callHistoryCore;
}

CallHistoryList::CallHistoryList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

CallHistoryList::~CallHistoryList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void CallHistoryList::setSelf(QSharedPointer<CallHistoryList> me) {
	mModelConnection = QSharedPointer<SafeConnection<CallHistoryList, CoreModel>>(
	    new SafeConnection<CallHistoryList, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);

	mModelConnection->makeConnectToCore(&CallHistoryList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			// Avoid copy to lambdas
			QList<QSharedPointer<CallHistoryCore>> *callLogs = new QList<QSharedPointer<CallHistoryCore>>();
			mustBeInLinphoneThread(getClassName());
			std::list<std::shared_ptr<linphone::CallLog>> linphoneCallLogs;
			if (auto account = CoreModel::getInstance()->getCore()->getDefaultAccount()) {
				linphoneCallLogs = account->getCallLogs();
			}
			for (auto it : linphoneCallLogs) {
				auto model = createCallHistoryCore(it);
				callLogs->push_back(model);
			}
			mModelConnection->invokeToCore([this, callLogs]() {
				mustBeInMainThread(getClassName());
				resetData<CallHistoryCore>(*callLogs);
				delete callLogs;
			});
		});
	});
	mModelConnection->makeConnectToModel(&CoreModel::defaultAccountChanged,
	                                     [this]() { mModelConnection->invokeToCore([this]() { lUpdate(); }); });
	mModelConnection->makeConnectToModel(
	    &CoreModel::callLogUpdated,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::CallLog> &callLog) {
		    QSharedPointer<CallHistoryCore> *callLogs = new QSharedPointer<CallHistoryCore>[1];
		    auto model = createCallHistoryCore(callLog);
		    callLogs[0] = model;
		    mModelConnection->invokeToCore([this, callLogs]() {
			    auto oldLog = std::find_if(mList.begin(), mList.end(), [callLogs](QSharedPointer<QObject> log) {
				    return (*callLogs)->mCallId == log.objectCast<CallHistoryCore>()->mCallId;
			    });
			    if (oldLog == mList.end()) { // New
				    prepend(*callLogs);
			    } else { // Update
				    qWarning() << log()
				                      .arg("LinphoneCore::onCallLogUpdated has been call for an existant log which "
				                           "should not be the "
				                           "case. Check with the SDK. CallID=%1")
				                      .arg((*callLogs)->mCallId);
			    }
			    delete[] callLogs;
		    });
	    });
	emit lUpdate();
}

void CallHistoryList::removeAllEntries() {
	beginResetModel();
	for (auto it = mList.rbegin(); it != mList.rend(); ++it) {
		auto callHistory = it->objectCast<CallHistoryCore>();
		callHistory->remove();
	}
	mList.clear();
	endResetModel();
}

void CallHistoryList::remove(const int &row) {
	beginRemoveRows(QModelIndex(), row, row);
	auto item = mList[row].objectCast<CallHistoryCore>();
	item->remove();
	endRemoveRows();
}

QVariant CallHistoryList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new CallHistoryGui(mList[row].objectCast<CallHistoryCore>()));
	}
	return QVariant();
}
