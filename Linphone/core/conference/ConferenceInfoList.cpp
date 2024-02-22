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

#include "ConferenceInfoList.hpp"
#include "ConferenceInfoCore.hpp"
#include "ConferenceInfoGui.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include "tool/Utils.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(ConferenceInfoList)

QSharedPointer<ConferenceInfoList> ConferenceInfoList::create() {
	auto model = QSharedPointer<ConferenceInfoList>(new ConferenceInfoList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

ConferenceInfoList::ConferenceInfoList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
}

ConferenceInfoList::~ConferenceInfoList() {
	mustBeInMainThread("~" + getClassName());
	mCoreModelConnection = nullptr;
}

void ConferenceInfoList::setSelf(QSharedPointer<ConferenceInfoList> me) {
	mCoreModelConnection = QSharedPointer<SafeConnection<ConferenceInfoList, CoreModel>>(
	    new SafeConnection<ConferenceInfoList, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);

	mCoreModelConnection->makeConnectToCore(&ConferenceInfoList::lUpdate, [this]() {
		mCoreModelConnection->invokeToModel([this]() {
			QList<QSharedPointer<ConferenceInfoCore>> *items = new QList<QSharedPointer<ConferenceInfoCore>>();
			mustBeInLinphoneThread(getClassName());
			std::list<std::shared_ptr<linphone::ConferenceInfo>> conferenceInfos =
			    CoreModel::getInstance()->getCore()->getDefaultAccount()->getConferenceInformationList();
			for (auto conferenceInfo : conferenceInfos) {
				auto confInfoCore = build(conferenceInfo);
				if (confInfoCore) items->push_back(confInfoCore);
			}
			mCoreModelConnection->invokeToCore([this, items]() {
				mustBeInMainThread(getClassName());
				resetData();
				add(*items);
				delete items;
			});
		});
	});
	// mCoreModelConnection->makeConnectToModel(
	//     &CoreModel::conferenceInfoReceived,
	//     [this](const std::shared_ptr<linphone::Core> core,
	//            const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo) {
	// 	    auto realConferenceInfo = CoreModel::getInstance()->getCore()->findConferenceInformationFromUri(
	// 	        conferenceInfo->getUri()->clone());
	// 	    // auto realConferenceInfo = ConferenceInfoModel::findConferenceInfo(conferenceInfo);
	// 	    if (realConferenceInfo) {
	// 		    auto model = get(realConferenceInfo);
	// 		    if (model) {
	// 			    // model->setConferenceInfo(realConferenceInfo);
	// 		    } else {
	// 			    auto confInfo = build(realConferenceInfo);
	// 			    if (confInfo) add(confInfo);
	// 		    }
	// 	    } else
	// 		    qWarning() << "No ConferenceInfo have beend found for " << conferenceInfo->getUri()->asString().c_str();
	//     });

	mCoreModelConnection->makeConnectToModel(&CoreModel::conferenceInfoReceived, &ConferenceInfoList::lUpdate);
	mCoreModelConnection->makeConnectToModel(&CoreModel::conferenceStateChanged, [this] {
		qDebug() << "list: conf state changed";
		lUpdate();
	});
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::conferenceInfoReceived,
	    [this](const std::shared_ptr<linphone::Core> &core,
	           const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo) {
		    qDebug() << "info received" << conferenceInfo->getOrganizer()->asStringUriOnly()
		             << conferenceInfo->getSubject();
	    });
	emit lUpdate();
}

QSharedPointer<ConferenceInfoCore>
ConferenceInfoList::get(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo) const {
	auto uri = Utils::coreStringToAppString(conferenceInfo->getUri()->asStringUriOnly());
	for (auto item : mList) {
		auto model = item.objectCast<ConferenceInfoCore>();
		auto confUri = model->getUri();
		if (confUri == uri) {
			return model;
		}
	}
	return nullptr;
}

QSharedPointer<ConferenceInfoCore>
ConferenceInfoList::build(const std::shared_ptr<linphone::ConferenceInfo> &conferenceInfo) const {
	auto me = CoreModel::getInstance()->getCore()->getDefaultAccount()->getParams()->getIdentityAddress();
	qDebug() << "[CONFERENCEINFOLIST] looking for me " << me->asStringUriOnly();
	std::list<std::shared_ptr<linphone::ParticipantInfo>> participants = conferenceInfo->getParticipantInfos();
	bool haveMe = conferenceInfo->getOrganizer()->weakEqual(me);
	if (!haveMe)
		haveMe = (std::find_if(participants.begin(), participants.end(),
		                       [me](const std::shared_ptr<linphone::ParticipantInfo> &p) {
			                       //    qDebug()
			                       //    << "[CONFERENCEINFOLIST] participant " << p->getAddress()->asStringUriOnly();
			                       return me->weakEqual(p->getAddress());
		                       }) != participants.end());
	if (haveMe) {
		auto conferenceModel = ConferenceInfoCore::create(conferenceInfo);
		connect(conferenceModel.get(), &ConferenceInfoCore::removed, this, &ConferenceInfoList::lUpdate);
		return conferenceModel;
	} else return nullptr;
}

void ConferenceInfoList::remove(const int &row) {
	// beginRemoveRows(QModelIndex(), row, row);
	auto item = mList[row].objectCast<ConferenceInfoCore>();
	emit item->lDeleteConferenceInfo();
	// endRemoveRows();
}

QHash<int, QByteArray> ConferenceInfoList::roleNames() const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	roles[Qt::DisplayRole + 1] = "$sectionMonth";
	return roles;
}

QVariant ConferenceInfoList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new ConferenceInfoGui(mList[row].objectCast<ConferenceInfoCore>()));
	} else if (role == Qt::DisplayRole + 1) {
		return Utils::toDateMonthString(mList[row].objectCast<ConferenceInfoCore>()->getDateTimeUtc());
	}
	return QVariant();
}
