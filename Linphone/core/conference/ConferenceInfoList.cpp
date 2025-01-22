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
#include "model/tool/ToolModel.hpp"
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
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	connect(App::getInstance(), &App::currentDateChanged, this, [this] {
		updateHaveCurrentDate();
		int dummyIndex = -1;
		get(nullptr, &dummyIndex);
		if (dummyIndex != -1) emit dataChanged(index(dummyIndex, 0), index(dummyIndex, 0));
	});
}

ConferenceInfoList::~ConferenceInfoList() {
	mustBeInMainThread("~" + getClassName());
	mCoreModelConnection = nullptr;
}

void ConferenceInfoList::setSelf(QSharedPointer<ConferenceInfoList> me) {
	mCoreModelConnection = SafeConnection<ConferenceInfoList, CoreModel>::create(me, CoreModel::getInstance());

	mCoreModelConnection->makeConnectToCore(&ConferenceInfoList::lUpdate, [this](bool isInitialization) {
		mCoreModelConnection->invokeToModel([this, isInitialization]() {
			QList<QSharedPointer<ConferenceInfoCore>> *items = new QList<QSharedPointer<ConferenceInfoCore>>();
			mustBeInLinphoneThread(getClassName());
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (!defaultAccount) return;
			std::list<std::shared_ptr<linphone::ConferenceInfo>> conferenceInfos =
			    defaultAccount->getConferenceInformationList();
			items->push_back(nullptr); // Add Dummy conference for today
			for (auto conferenceInfo : conferenceInfos) {
				if (conferenceInfo->getState() == linphone::ConferenceInfo::State::Cancelled) {
					auto myAddress = defaultAccount->getParams()->getIdentityAddress();
					if (!myAddress || myAddress->weakEqual(conferenceInfo->getOrganizer())) continue;
				}
				auto confInfoCore = build(conferenceInfo);
				// Cancelled conference organized ourself me must be hidden
				if (confInfoCore) {
					// qDebug() << log().arg("Add conf") << confInfoCore->getSubject() << "with state"
					//  << confInfoCore->getConferenceInfoState();
					items->push_back(confInfoCore);
				}
			}
			mCoreModelConnection->invokeToCore([this, items, isInitialization]() {
				mustBeInMainThread(getClassName());
				for (auto &item : *items) {
					connectItem(item);
				}
				resetData(*items);
				delete items;
				if (isInitialization) {
					emit initialized();
				}
			});
		});
	});

	// This is needed because account does not have a contact address until
	// it is connected, so we can't verify if it is the organizer of a deleted
	// conference (which must hidden)
	mCoreModelConnection->makeConnectToModel(&CoreModel::defaultAccountChanged, [this]() { emit lUpdate(true); });

	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::conferenceInfoCreated,
	    [this](const std::shared_ptr<linphone::ConferenceInfo> &confInfo) { addConference(confInfo); });
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::conferenceInfoReceived,
	    [this](const std::shared_ptr<linphone::Core> &core,
	           const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo) {
		    lDebug() << log().arg("conference info received") << conferenceInfo->getSubject();
		    addConference(conferenceInfo->clone());
	    });
	emit lUpdate(true);
}

void ConferenceInfoList::resetData(QList<QSharedPointer<ConferenceInfoCore>> data) {
	beginResetModel();
	mList.clear();
	for (auto i : data)
		mList << i.template objectCast<QObject>();
	updateHaveCurrentDate(); // Set have current date before resetting models to let proxy having this info.
	endResetModel();
}

void ConferenceInfoList::addConference(const std::shared_ptr<linphone::ConferenceInfo> &confInfo) {
	auto list = getSharedList<ConferenceInfoCore>();
	auto haveConf = std::find_if(list.begin(), list.end(), [confInfo](const QSharedPointer<ConferenceInfoCore> &item) {
		std::shared_ptr<linphone::Address> confAddr = nullptr;
		if (item) ToolModel::interpretUrl(item->getUri());
		return confInfo->getUri()->weakEqual(confAddr);
	});
	if (haveConf == list.end()) {
		auto confInfoCore = build(confInfo);
		mCoreModelConnection->invokeToCore([this, confInfoCore] {
			connectItem(confInfoCore);
			add(confInfoCore);
			updateHaveCurrentDate();
			emit confInfoInserted(confInfoCore);
		});
	}
}

bool ConferenceInfoList::haveCurrentDate() const {
	return mHaveCurrentDate;
}

void ConferenceInfoList::setHaveCurrentDate(bool have) {
	if (mHaveCurrentDate != have) {
		mHaveCurrentDate = have;
		emit haveCurrentDateChanged();
	}
}

void ConferenceInfoList::updateHaveCurrentDate() {
	auto today = QDate::currentDate();
	auto confInfoList = getSharedList<ConferenceInfoCore>();
	auto haveCurrent =
	    std::find_if(confInfoList.begin(), confInfoList.end(), [today](const QSharedPointer<ConferenceInfoCore> &item) {
		    return item && item->getDateTimeUtc().date() == today;
	    });
	setHaveCurrentDate(haveCurrent != confInfoList.end());
}

int ConferenceInfoList::getCurrentDateIndex() {
	auto today = QDate::currentDate();
	auto confInfoList = getSharedList<ConferenceInfoCore>();
	QList<QSharedPointer<ConferenceInfoCore>>::iterator it;
	if (mHaveCurrentDate) {
		it = std::find_if(confInfoList.begin(), confInfoList.end(),
		                  [today](const QSharedPointer<ConferenceInfoCore> &item) {
			                  return item && item->getDateTimeUtc().date() == today;
		                  });
	} else it = std::find(confInfoList.begin(), confInfoList.end(), nullptr);
	return it == confInfoList.end() ? -1 : std::distance(confInfoList.begin(), it);
}

QSharedPointer<ConferenceInfoCore> ConferenceInfoList::getCurrentDateConfInfo() {
	auto today = QDate::currentDate();
	auto confInfoList = getSharedList<ConferenceInfoCore>();
	QList<QSharedPointer<ConferenceInfoCore>>::iterator it;
	if (mHaveCurrentDate) {
		it = std::find_if(confInfoList.begin(), confInfoList.end(),
		                  [today](const QSharedPointer<ConferenceInfoCore> &item) {
			                  return item && item->getDateTimeUtc().date() == today;
		                  });
	} else it = std::find(confInfoList.begin(), confInfoList.end(), nullptr);
	return it != confInfoList.end() ? *it : nullptr;
}

QSharedPointer<ConferenceInfoCore>
ConferenceInfoList::build(const std::shared_ptr<linphone::ConferenceInfo> &conferenceInfo) {
	auto me = CoreModel::getInstance()->getCore()->getDefaultAccount()->getParams()->getIdentityAddress();
	std::list<std::shared_ptr<linphone::ParticipantInfo>> participants = conferenceInfo->getParticipantInfos();
	bool haveMe = conferenceInfo->getOrganizer()->weakEqual(me);
	if (!haveMe)
		haveMe = (std::find_if(participants.begin(), participants.end(),
		                       [me](const std::shared_ptr<linphone::ParticipantInfo> &p) {
			                       return me->weakEqual(p->getAddress());
		                       }) != participants.end());
	if (haveMe) {
		auto confInfoCore = ConferenceInfoCore::create(conferenceInfo);
		return confInfoCore;
	} else return nullptr;
}

void ConferenceInfoList::connectItem(QSharedPointer<ConferenceInfoCore> confInfoCore) {
	if (confInfoCore) {
		connect(confInfoCore.get(), &ConferenceInfoCore::removed, this, [this](ConferenceInfoCore *confInfo) {
			remove(confInfo);
			updateHaveCurrentDate();
		});
		connect(confInfoCore.get(), &ConferenceInfoCore::dataSaved, this, [this, confInfoCore]() {
			int i = -1;
			get(confInfoCore.get(), &i);
			if (i != -1) {
				updateHaveCurrentDate();
				auto modelIndex = index(i);
				emit confInfoUpdated(confInfoCore);
				emit dataChanged(modelIndex, modelIndex);
			}
		});
	}
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
	auto conferenceInfo = mList[row].objectCast<ConferenceInfoCore>();
	if (conferenceInfo) {
		if (role == Qt::DisplayRole) {
			return QVariant::fromValue(new ConferenceInfoGui(mList[row].objectCast<ConferenceInfoCore>()));
		} else if (role == Qt::DisplayRole + 1) {
			return Utils::toDateMonthString(mList[row].objectCast<ConferenceInfoCore>()->getDateTimeUtc());
		}
	} else { // Dummy date
		if (role == Qt::DisplayRole) {
			return QVariant::fromValue(new ConferenceInfoGui(nullptr));
		} else if (role == Qt::DisplayRole + 1) {
			return Utils::toDateMonthString(QDateTime::currentDateTimeUtc());
		}
	}
	return QVariant();
}
