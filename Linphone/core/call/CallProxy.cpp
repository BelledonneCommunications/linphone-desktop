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

#include "CallProxy.hpp"
#include "CallGui.hpp"
#include "CallList.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(CallProxy)

CallProxy::CallProxy(QObject *parent) : LimitProxy(parent) {
}

CallProxy::~CallProxy() {
}

CallGui *CallProxy::getCurrentCall() {
	auto model = getListModel<CallList>();
	if (!mCurrentCall && model) mCurrentCall = model->getCurrentCall();
	return mCurrentCall;
}

void CallProxy::setCurrentCall(CallGui *call) {
	getListModel<CallList>()->setCurrentCall(call);
}

// Reset the default account to let UI build its new object if needed.
void CallProxy::resetCurrentCall() {
	mCurrentCall = nullptr;
	emit this->currentCallChanged(); // Warn the UI
}

bool CallProxy::getHaveCall() const {
	auto model = getListModel<CallList>();
	return model ? model->getHaveCall() : false;
}

void CallProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldCallList = getListModel<CallList>();
	if (oldCallList) {
		disconnect(oldCallList);
	}
	auto newCallList = dynamic_cast<CallList *>(model);
	if (newCallList) {
		connect(newCallList, &CallList::currentCallChanged, this, &CallProxy::resetCurrentCall, Qt::QueuedConnection);
		connect(newCallList, &CallList::haveCallChanged, this, &CallProxy::haveCallChanged, Qt::QueuedConnection);
		connect(this, &CallProxy::lMergeAll, newCallList, &CallList::lMergeAll);
	}
	setSourceModels(new SortFilterList(model));
}

bool CallProxy::SortFilterList::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		auto call = qobject_cast<CallList *>(sourceModel())->getAt<CallCore>(sourceRow);

		show = call->getRemoteAddress().contains(search);
	}

	return show;
}

bool CallProxy::SortFilterList::lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const {
	auto l = getItemAtSource<CallList, CallCore>(sourceLeft.row());
	auto r = getItemAtSource<CallList, CallCore>(sourceRight.row());

	return l->getRemoteAddress() < r->getRemoteAddress();
}
