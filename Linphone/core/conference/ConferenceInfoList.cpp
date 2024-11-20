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
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
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
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (!defaultAccount) return;
			std::list<std::shared_ptr<linphone::ConferenceInfo>> conferenceInfos =
			    defaultAccount->getConferenceInformationList();
			items->push_back(nullptr); // Add Dummy conference for today
			for (auto conferenceInfo : conferenceInfos) {
				auto confInfoCore = build(conferenceInfo);
				// Cancelled conference organized ourself me must be hidden
				if (conferenceInfo->getState() == linphone::ConferenceInfo::State::Cancelled) {
					auto myAddress = defaultAccount->getContactAddress();
					if (!myAddress || myAddress->weakEqual(conferenceInfo->getOrganizer())) continue;
				}
				if (confInfoCore) {
					qDebug() << log().arg("Add conf") << confInfoCore->getSubject() << "with state"
					         << confInfoCore->getConferenceInfoState();
					items->push_back(confInfoCore);
				}
			}
			mCoreModelConnection->invokeToCore([this, items]() {
				mustBeInMainThread(getClassName());
				int currentDateIndex = sort(*items);
				auto itemAfterDummy = currentDateIndex < items->size() - 1 ? items->at(currentDateIndex + 1) : nullptr;
				updateHaveCurrentDate(itemAfterDummy);
				resetData<ConferenceInfoCore>(*items);
				if (mLastConfInfoInserted) {
					int index = -1;
					// TODO : uncomment when linphone conference scheduler updated
					// and model returns the scheduler conferenceInfo uri
					index = findConfInfoIndexByUri(mLastConfInfoInserted->getUri());
					// int index2;
					// get(mLastConfInfoInserted.get(), &index2);
					if (index != -1) setCurrentDateIndex(index);
					else setCurrentDateIndex(mHaveCurrentDate ? currentDateIndex + 1 : currentDateIndex);
					mLastConfInfoInserted = nullptr;
				} else setCurrentDateIndex(mHaveCurrentDate ? currentDateIndex + 1 : currentDateIndex);
				delete items;
			});
		});
	});

	// This is needed because account does not have a contact address until
	// it is connected, so we can't verify if it is the organizer of a deleted
	// conference (which must hidden)
	auto connectModel = [this] {
		mCoreModelConnection->invokeToModel([this]() {
			if (mCurrentAccountCore) disconnect(mCurrentAccountCore.get());
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (defaultAccount) {
				mCurrentAccountCore = AccountCore::create(defaultAccount);
				connect(mCurrentAccountCore.get(), &AccountCore::registrationStateChanged, this,
				        &ConferenceInfoList::lUpdate);
			}
		});
	};
	mCoreModelConnection->makeConnectToModel(&CoreModel::defaultAccountChanged, connectModel);
	connectModel();

	mCoreModelConnection->makeConnectToModel(&CoreModel::conferenceInfoReceived, &ConferenceInfoList::lUpdate);
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::conferenceInfoCreated, [this](const std::shared_ptr<linphone::ConferenceInfo> &confInfo) {
		    auto confInfoCore = ConferenceInfoCore::create(confInfo);
		    auto haveConf =
		        std::find_if(mList.begin(), mList.end(), [confInfoCore](const QSharedPointer<QObject> &item) {
			        auto isConfInfo = item.objectCast<ConferenceInfoCore>();
			        if (!isConfInfo) return false;
			        return isConfInfo->getUri() == confInfoCore->getUri();
		        });
		    if (haveConf == mList.end()) {
			    mLastConfInfoInserted = confInfoCore;
			    emit lUpdate();
		    }
	    });
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::conferenceInfoReceived,
	    [this](const std::shared_ptr<linphone::Core> &core,
	           const std::shared_ptr<const linphone::ConferenceInfo> &conferenceInfo) {
		    lDebug() << log().arg("conference info received") << conferenceInfo->getOrganizer()->asStringUriOnly()
		             << conferenceInfo->getSubject();
	    });
	emit lUpdate();
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
	auto today = QDateTime::currentDateTimeUtc().date();
	for (auto item : mList) {
		auto model = item.objectCast<ConferenceInfoCore>();
		if (model && model->getDateTimeUtc().date() == today) {
			setHaveCurrentDate(true);
			return;
		}
	}
	setHaveCurrentDate(false);
}

void ConferenceInfoList::updateHaveCurrentDate(QSharedPointer<ConferenceInfoCore> itemToCompare) {
	setHaveCurrentDate(itemToCompare &&
	                   itemToCompare->getDateTimeUtc().date() == QDateTime::currentDateTimeUtc().date());
}

int ConferenceInfoList::getCurrentDateIndex() const {
	return mCurrentDateIndex;
}

void ConferenceInfoList::setCurrentDateIndex(int index) {
	if (mCurrentDateIndex != index) {
		mCurrentDateIndex = index;
		emit currentDateIndexChanged();
	}
}

int ConferenceInfoList::findConfInfoIndexByUri(const QString &uri) {
	auto items = getSharedList<ConferenceInfoCore>();
	for (int i = 0; i < items.size(); ++i) {
		if (!items[i]) continue;
		if (items[i]->getUri() == uri) return i;
	}
	return -1;
}

QSharedPointer<ConferenceInfoCore>
ConferenceInfoList::build(const std::shared_ptr<linphone::ConferenceInfo> &conferenceInfo) const {
	auto me = CoreModel::getInstance()->getCore()->getDefaultAccount()->getParams()->getIdentityAddress();
	std::list<std::shared_ptr<linphone::ParticipantInfo>> participants = conferenceInfo->getParticipantInfos();
	bool haveMe = conferenceInfo->getOrganizer()->weakEqual(me);
	if (!haveMe)
		haveMe = (std::find_if(participants.begin(), participants.end(),
		                       [me](const std::shared_ptr<linphone::ParticipantInfo> &p) {
			                       return me->weakEqual(p->getAddress());
		                       }) != participants.end());
	if (haveMe) {
		auto conferenceModel = ConferenceInfoCore::create(conferenceInfo);
		connect(conferenceModel.get(), &ConferenceInfoCore::removed, this, &ConferenceInfoList::lUpdate);
		return conferenceModel;
	} else return nullptr;
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
			return QVariant::fromValue(new ConferenceInfoGui());
		} else if (role == Qt::DisplayRole + 1) {
			return Utils::toDateMonthString(QDateTime::currentDateTimeUtc());
		}
	}
	return QVariant();
}

int ConferenceInfoList::sort(QList<QSharedPointer<ConferenceInfoCore>> &listToSort) {
	auto nowDate = QDateTime(QDate::currentDate(), QTime(0, 0, 0)).toUTC().date();
	std::sort(listToSort.begin(), listToSort.end(),
	          [nowDate](const QSharedPointer<QObject> &a, const QSharedPointer<QObject> &b) {
		          auto l = a.objectCast<ConferenceInfoCore>();
		          auto r = b.objectCast<ConferenceInfoCore>();
		          if (!l || !r) { // sort on date
			          return !l ? nowDate <= r->getDateTimeUtc().date() : l->getDateTimeUtc().date() < nowDate;
		          } else {
			          return l->getDateTimeUtc() < r->getDateTimeUtc();
		          }
	          });
	auto it = std::find(listToSort.begin(), listToSort.end(), nullptr);
	return it == listToSort.end() ? -1 : it - listToSort.begin();
}
