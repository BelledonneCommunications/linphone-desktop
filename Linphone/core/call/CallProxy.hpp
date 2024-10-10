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

#ifndef CALL_PROXY_H_
#define CALL_PROXY_H_

#include "../proxy/LimitProxy.hpp"
#include "core/call/CallGui.hpp"
#include "core/call/CallList.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class CallProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(CallGui *currentCall READ getCurrentCall WRITE setCurrentCall NOTIFY currentCallChanged)
	Q_PROPERTY(bool haveCall READ getHaveCall NOTIFY haveCallChanged)

public:
	DECLARE_SORTFILTER_CLASS()

	CallProxy(QObject *parent = Q_NULLPTR);
	~CallProxy();

	// Get a new object from List or give the stored one.
	CallGui *getCurrentCall();
	// TODO for manual setting. Changing the currentCall is automatically done by call->onStateChanged() on
	// StreamRunning and Resuming
	void setCurrentCall(CallGui *call);
	void resetCurrentCall(); // Reset the default account to let UI build its new object if needed.

	bool getHaveCall() const;

	void setSourceModel(QAbstractItemModel *sourceModel) override;

signals:
	void lMergeAll();
	void currentCallChanged();
	void haveCallChanged();

protected:
	CallGui *mCurrentCall = nullptr; // When null, a new UI object is build from List

	DECLARE_ABSTRACT_OBJECT
};

#endif
