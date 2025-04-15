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

#ifndef CALL_LIST_H_
#define CALL_LIST_H_

#include "../proxy/ListProxy.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QLocale>

class CallGui;
class CallCore;
class CoreModel;
// =============================================================================

class CallList : public ListProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(CallGui* currentCall READ getCurrentCall WRITE setCurrentCall NOTIFY currentCallChanged)
public:
	static QSharedPointer<CallList> create();
	// Create a CallCore and make connections to List.
	QSharedPointer<CallCore> createCallCore(const std::shared_ptr<linphone::Call> &call);
	CallList(QObject *parent = Q_NULLPTR);
	~CallList();

	void setSelf(QSharedPointer<CallList> me);

	CallGui *getCurrentCall() const; // Used for Ui
	QSharedPointer<CallCore> getCurrentCallCore() const;
	void setCurrentCall(CallGui* callGui);
	void setCurrentCallCore(QSharedPointer<CallCore> call);

	bool getHaveCall() const;
	void setHaveCall(bool haveCall);

	// Get the next call after the current one. Used to switch the current call.
	// At the moment, it select the last call in the list.
	QSharedPointer<CallCore> getNextCall() const;

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
signals:
	void lUpdate();
	void lMergeAll();
	void haveCallChanged();
	void currentCallChanged();

private:
	// Check the state from CallCore: sender() must be a CallCore.
	void onStateChanged();

	bool mHaveCall = false;
	QSharedPointer<CallCore> mCurrentCall;
	QSharedPointer<SafeConnection<CallList, CoreModel>> mModelConnection;
	DECLARE_ABSTRACT_OBJECT
};

#endif
