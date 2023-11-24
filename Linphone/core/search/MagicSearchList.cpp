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
#include "core/friend/FriendGui.hpp"
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
	App::postModelSync([this]() {
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		auto linphoneSearch = CoreModel::getInstance()->getCore()->createMagicSearch();
		linphoneSearch->setLimitedSearch(false);
		mMagicSearch = Utils::makeQObject_ptr<MagicSearchModel>(linphoneSearch);
		mMagicSearch->mSourceFlags =
		    (int)linphone::MagicSearch::Source::Friends | (int)linphone::MagicSearch::Source::LdapServers;
		mMagicSearch->mAggregationFlag = linphone::MagicSearch::Aggregation::Friend;
		mMagicSearch->setSelf(mMagicSearch);
	});
}

MagicSearchList::~MagicSearchList() {
	mustBeInMainThread("~" + getClassName());
}

void MagicSearchList::setSelf(QSharedPointer<MagicSearchList> me) {
	mModelConnection = QSharedPointer<SafeConnection>(
	    new SafeConnection(me.objectCast<QObject>(), std::dynamic_pointer_cast<QObject>(mMagicSearch)),
	    &QObject::deleteLater);
	mModelConnection->makeConnect(this, &MagicSearchList::lSearch, [this](QString filter) {
		mModelConnection->invokeToModel([this, filter]() { mMagicSearch->search(filter); });
	});
	mModelConnection->makeConnect(mMagicSearch.get(), &MagicSearchModel::searchResultsReceived,
	                              [this](const std::list<std::shared_ptr<linphone::SearchResult>> &results) {
		                              auto *contacts = new QList<QSharedPointer<FriendCore>>();
		                              for (auto it : results) {
			                              QSharedPointer<FriendCore> contact;
			                              if (it->getFriend()) {
				                              contact = FriendCore::create(it->getFriend());
				                              contacts->append(contact);
			                              }
		                              }
		                              mModelConnection->invokeToCore([this, contacts]() {
			                              setResults(*contacts);
			                              delete contacts;
		                              });
	                              });
}

void MagicSearchList::setResults(const QList<QSharedPointer<FriendCore>> &contacts) {
	resetData();
	for (auto it : contacts) {
		connect(it.get(), &FriendCore::removed, this, qOverload<QObject *>(&MagicSearchList::remove));
	}
	add(contacts);
}

void MagicSearchList::setSearch(const QString &search) {
	if (!search.isEmpty()) {
		lSearch(search);
	} else {
		beginResetModel();
		mList.clear();
		endResetModel();
	}
}

QVariant MagicSearchList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new FriendGui(mList[row].objectCast<FriendCore>()));
	return QVariant();
}
