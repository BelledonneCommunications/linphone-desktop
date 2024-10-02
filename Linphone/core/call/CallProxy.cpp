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

CallProxy::CallProxy(QObject *parent) : SortFilterProxy(parent) {
	setSourceModel(App::getInstance()->getCallList().get());
	sort(0);
}

CallProxy::~CallProxy() {
	setSourceModel(nullptr);
}

QString CallProxy::getFilterText() const {
	return mFilterText;
}

void CallProxy::setFilterText(const QString &filter) {
	if (mFilterText != filter) {
		mFilterText = filter;
		invalidate();
		emit filterTextChanged();
	}
}

CallGui *CallProxy::getCurrentCall() {
	if (!mCurrentCall) mCurrentCall = dynamic_cast<CallList *>(sourceModel())->getCurrentCall();
	return mCurrentCall;
}

void CallProxy::setCurrentCall(CallGui *call) {
	dynamic_cast<CallList *>(sourceModel())->setCurrentCall(call->mCore);
}

// Reset the default account to let UI build its new object if needed.
void CallProxy::resetCurrentCall() {
	mCurrentCall = nullptr;
	emit this->currentCallChanged(); // Warn the UI
}

bool CallProxy::getHaveCall() const {
	return dynamic_cast<CallList *>(sourceModel())->getHaveCall();
}

void CallProxy::setSourceModel(QAbstractItemModel *model) {
	auto oldCallList = dynamic_cast<CallList *>(sourceModel());
	if (oldCallList) {
		disconnect(oldCallList);
	}
	auto newCallList = dynamic_cast<CallList *>(model);
	if (newCallList) {
		connect(newCallList, &CallList::currentCallChanged, this, &CallProxy::resetCurrentCall, Qt::QueuedConnection);
		connect(newCallList, &CallList::haveCallChanged, this, &CallProxy::haveCallChanged, Qt::QueuedConnection);
		connect(this, &CallProxy::lMergeAll, newCallList, &CallList::lMergeAll);
	}
	QSortFilterProxyModel::setSourceModel(model);
}

bool CallProxy::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const {
	bool show = (mFilterText.isEmpty() || mFilterText == "*");
	if (!show) {
		QRegularExpression search(QRegularExpression::escape(mFilterText),
		                          QRegularExpression::CaseInsensitiveOption |
		                              QRegularExpression::UseUnicodePropertiesOption);
		QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
		auto model = sourceModel()->data(index);
		auto call = model.value<CallGui *>();
		show = call->getCore()->getPeerAddress().contains(search);
	}

	return show;
}

bool CallProxy::lessThan(const QModelIndex &left, const QModelIndex &right) const {
	auto l = sourceModel()->data(left);
	auto r = sourceModel()->data(right);

	return l.value<CallGui *>()->getCore()->getPeerAddress() < r.value<CallGui *>()->getCore()->getPeerAddress();
}
