
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

#include "EmojiProxy.hpp"
#include "EmojiList.hpp"
#include "core/App.hpp"
// #include "core/chat/message/ChatMessageGui.hpp"

DEFINE_ABSTRACT_OBJECT(EmojiProxy)

EmojiProxy::EmojiProxy(QObject *parent) : LimitProxy(parent) {
	mList = EmojiList::create();
	setSourceModel(mList.get());
	connect(mList.get(), &EmojiList::reactionsChanged, this, &EmojiProxy::reactionsChanged);
	connect(this, &EmojiProxy::filterChanged, this, [this] { invalidate(); });
}

EmojiProxy::~EmojiProxy() {
}

QList<Reaction> EmojiProxy::getReactions() {
	return mList->getReactions();
}

void EmojiProxy::setReactions(QList<Reaction> reactions) {
	mList->setReactions(reactions);
}

QString EmojiProxy::getFilter() const {
	return mFilter;
}

void EmojiProxy::setFilter(QString filter) {
	if (mFilter != filter) {
		mFilter = filter;
		emit filterChanged();
	}
}

bool EmojiProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	auto emoji = mList->getAt(sourceRow);
	return emoji.mBody.contains(mFilter);
}

bool EmojiProxy::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	return true;
}
