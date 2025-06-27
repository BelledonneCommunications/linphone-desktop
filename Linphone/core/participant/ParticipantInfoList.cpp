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

#include "ParticipantInfoList.hpp"
#include "core/App.hpp"
#include "core/chat/ChatCore.hpp"
#include "core/participant/ParticipantGui.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(ParticipantInfoList)

QSharedPointer<ParticipantInfoList> ParticipantInfoList::create() {
	auto model = QSharedPointer<ParticipantInfoList>(new ParticipantInfoList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	return model;
}

QSharedPointer<ParticipantInfoList> ParticipantInfoList::create(const QSharedPointer<ChatCore> &chatCore) {
	auto model = create();
	model->setChatCore(chatCore);
	return model;
}

ParticipantInfoList::ParticipantInfoList(QObject *parent) : ListProxy(parent) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

ParticipantInfoList::~ParticipantInfoList() {
	mList.clear();
}

void ParticipantInfoList::setChatCore(const QSharedPointer<ChatCore> &chatCore) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mChatCore) disconnect(mChatCore.get());
	mChatCore = chatCore;
	lDebug() << "[ParticipantInfoList] : set Chat " << mChatCore.get();
	clearData();
	if (mChatCore) {
		auto buildList = [this] {
			QStringList participantAddresses;
			QList<QSharedPointer<ParticipantGui>> participantList;
			auto participants = mChatCore->getParticipants();
			resetData<ParticipantCore>(participants);
		};
		connect(mChatCore.get(), &ChatCore::participantsChanged, this, buildList);
		buildList();
	}
}

QVariant ParticipantInfoList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new ParticipantGui(mList[row].objectCast<ParticipantCore>()));
	}
	return QVariant();
}