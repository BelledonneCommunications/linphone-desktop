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

#include "MagicSearchList.hpp"
#include "core/App.hpp"
#include "core/friend/FriendCore.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(MagicSearchList)

QSharedPointer<MagicSearchList> MagicSearchList::create() {
	auto model = QSharedPointer<MagicSearchList>(new MagicSearchList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

MagicSearchList::MagicSearchList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mSourceFlags = (int)linphone::MagicSearch::Source::Friends | (int)linphone::MagicSearch::Source::LdapServers;
	mAggregationFlag = LinphoneEnums::MagicSearchAggregation::Friend;
	mSearchFilter = "*";
}

MagicSearchList::~MagicSearchList() {
	mustBeInMainThread("~" + getClassName());
}

void MagicSearchList::setSelf(QSharedPointer<MagicSearchList> me) {
	mCoreModelConnection = SafeConnection<MagicSearchList, CoreModel>::create(me, CoreModel::getInstance());
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::friendCreated, [this](const std::shared_ptr<linphone::Friend> &f) {
		    auto friendCore = FriendCore::create(f);
		    auto haveContact =
		        std::find_if(mList.begin(), mList.end(), [friendCore](const QSharedPointer<QObject> &item) {
			        auto itemCore = item.objectCast<FriendCore>();
			        auto itemModel = itemCore->getFriendModel();
			        auto friendModel = friendCore->getFriendModel();
			        return itemCore->getDefaultAddress().length() > 0 &&
			                   itemCore->getDefaultAddress() == friendCore->getDefaultAddress() ||
			               itemModel && friendModel && itemModel->getFriend() == friendModel->getFriend() &&
			                   itemModel->getFriend()->getFriendList()->getDisplayName() ==
			                       friendModel->getFriend()->getFriendList()->getDisplayName();
		        });
		    if (haveContact == mList.end()) {
			    connect(friendCore.get(), &FriendCore::removed, this, qOverload<QObject *>(&MagicSearchList::remove));
			    add(friendCore);
			    emit friendCreated(getCount() - 1, new FriendGui(friendCore));
		    }
	    });
	mCoreModelConnection->invokeToModel([this] {
		auto linphoneSearch = CoreModel::getInstance()->getCore()->createMagicSearch();
		linphoneSearch->setLimitedSearch(false);
		auto magicSearch = Utils::makeQObject_ptr<MagicSearchModel>(linphoneSearch);
		mCoreModelConnection->invokeToCore([this, magicSearch] {
			mMagicSearch = magicSearch;
			mMagicSearch->setSelf(mMagicSearch);
			mModelConnection = SafeConnection<MagicSearchList, MagicSearchModel>::create(
			    mCoreModelConnection->mCore.mQData, mMagicSearch);
			mModelConnection->makeConnectToCore(
			    &MagicSearchList::lSearch,
			    [this](QString filter, int sourceFlags, LinphoneEnums::MagicSearchAggregation aggregationFlag,
			           int maxResults) {
				    resetData();
				    mModelConnection->invokeToModel([this, filter, sourceFlags, aggregationFlag, maxResults]() {
					    mMagicSearch->search(filter, sourceFlags, aggregationFlag, maxResults);
				    });
			    });
			mModelConnection->makeConnectToModel(
			    &MagicSearchModel::searchResultsReceived,
			    [this](const std::list<std::shared_ptr<linphone::SearchResult>> &results) {
				    auto *contacts = new QList<QSharedPointer<FriendCore>>();
				    auto ldapContacts = ToolModel::getLdapFriendList();

				    for (auto it : results) {
					    QSharedPointer<FriendCore> contact;
					    auto linphoneFriend = it->getFriend();
					    bool isStored = false;
					    if (linphoneFriend) {
						    isStored =
						        (ldapContacts->findFriendByAddress(linphoneFriend->getAddress()) != linphoneFriend);
						    contact = FriendCore::create(linphoneFriend, isStored, it->getSourceFlags());
						    contacts->append(contact);
					    } else if (auto address = it->getAddress()) {
						    auto linphoneFriend = CoreModel::getInstance()->getCore()->createFriend();
						    linphoneFriend->setAddress(address);
						    contact = FriendCore::create(linphoneFriend, isStored, it->getSourceFlags());
						    auto displayName = Utils::coreStringToAppString(address->getDisplayName());
						    auto splitted = displayName.split(" ");
						    if (!displayName.isEmpty() && splitted.size() > 0) {
							    contact->setGivenName(splitted[0]);
							    splitted.removeFirst();
							    contact->setFamilyName(splitted.join(" "));
						    } else {
							    contact->setGivenName(Utils::coreStringToAppString(address->getUsername()));
						    }
						    contact->setDefaultFullAddress(Utils::coreStringToAppString(
						        address->asString())); // linphone Friend object remove specific address.
						    contacts->append(contact);
					    } else if (!it->getPhoneNumber().empty()) {
						    auto phoneNumber = it->getPhoneNumber();
						    linphoneFriend = CoreModel::getInstance()->getCore()->createFriend();
						    linphoneFriend->addPhoneNumber(phoneNumber);
						    contact = FriendCore::create(linphoneFriend, isStored, it->getSourceFlags());
						    contact->setGivenName(Utils::coreStringToAppString(it->getPhoneNumber()));
						    contact->appendPhoneNumber(tr("device_id"),
						                               Utils::coreStringToAppString(it->getPhoneNumber()));
						    contacts->append(contact);
					    }
				    }
				    mModelConnection->invokeToCore([this, contacts]() {
					    setResults(*contacts);
					    delete contacts;
					    emit resultsProcessed();
				    });
			    });
			qDebug() << log().arg("Initialized");
			emit initialized();
		});
	});
}

void MagicSearchList::connectContact(FriendCore *data) {
	connect(data, &FriendCore::removed, this, qOverload<QObject *>(&MagicSearchList::remove));
	connect(data, &FriendCore::starredChanged, this, &MagicSearchList::friendStarredChanged);
}

void MagicSearchList::setResults(const QList<QSharedPointer<FriendCore>> &contacts) {
	for (auto item : mList) {
		auto isFriendCore = item.objectCast<FriendCore>();
		if (!isFriendCore) continue;
		disconnect(isFriendCore.get());
	}
	qDebug() << log().arg("SetResults: %1").arg(contacts.size());
	resetData<FriendCore>(contacts);
	for (auto it : contacts) {
		connectContact(it.get());
	}
}

void MagicSearchList::add(QSharedPointer<FriendCore> contact) {
	connectContact(contact.get());
	ListProxy::add(contact);
}

void MagicSearchList::setSearch(const QString &search) {
	mSearchFilter = search;
	if (!search.isEmpty()) {
		emit lSearch(search, mSourceFlags, mAggregationFlag, mMaxResults);
	} else {
		beginResetModel();
		mList.clear();
		endResetModel();
	}
}

int MagicSearchList::getSourceFlags() const {
	return mSourceFlags;
}

void MagicSearchList::setSourceFlags(int flags) {
	if (mSourceFlags != flags) {
		mSourceFlags = flags;
		emit sourceFlagsChanged(mSourceFlags);
	}
}

int MagicSearchList::getMaxResults() const {
	return mMaxResults;
}

void MagicSearchList::setMaxResults(int maxResults) {
	if (mMaxResults != maxResults) {
		mMaxResults = maxResults;
		emit maxResultsChanged(mMaxResults);
	}
}

LinphoneEnums::MagicSearchAggregation MagicSearchList::getAggregationFlag() const {
	return mAggregationFlag;
}

void MagicSearchList::setAggregationFlag(LinphoneEnums::MagicSearchAggregation flags) {
	if (mAggregationFlag != flags) {
		mAggregationFlag = flags;
		emit aggregationFlagChanged(mAggregationFlag);
	}
}

QHash<int, QByteArray> MagicSearchList::roleNames() const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	roles[Qt::DisplayRole + 1] = "isStored";
	return roles;
}

QVariant MagicSearchList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new FriendGui(mList[row].objectCast<FriendCore>()));
	} else if (role == Qt::DisplayRole + 1) {
		return mList[row].objectCast<FriendCore>()->getIsStored() || mList[row].objectCast<FriendCore>()->isLdap() ||
		       mList[row].objectCast<FriendCore>()->isCardDAV();
	}
	return QVariant();
}

int MagicSearchList::findFriendIndexByAddress(const QString &address) {
	for (int i = 0; i < getCount(); ++i) {
		auto friendCore = getAt<FriendCore>(i);
		if (!friendCore) continue;
		for (auto &friendAddress : friendCore->getAllAddresses()) {
			auto map = friendAddress.toMap();
			if (map["address"].toString() == address) {
				return i;
			}
		}
	}
	return -1;
}

QSharedPointer<FriendCore> MagicSearchList::findFriendByAddress(const QString &address) {
	for (int i = 0; i < getCount(); ++i) {
		auto friendCore = getAt<FriendCore>(i);
		if (!friendCore) continue;
		for (auto &friendAddress : friendCore->getAllAddresses()) {
			auto map = friendAddress.toMap();
			if (map["address"].toString() == address) {
				return friendCore;
			}
		}
	}
	return nullptr;
}
