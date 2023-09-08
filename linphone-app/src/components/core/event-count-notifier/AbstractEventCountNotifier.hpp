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

#ifndef ABSTRACT_EVENT_COUNT_NOTIFIER_H_
#define ABSTRACT_EVENT_COUNT_NOTIFIER_H_

#include <QSharedPointer>

#include <QHash>
#include <QObject>
#include <QPair>

// =============================================================================

namespace linphone {
class ChatMessage;
}

class CallModel;
class ChatRoomModel;
class HistoryModel;

class AbstractEventCountNotifier : public QObject {
	Q_OBJECT
	
public:
	AbstractEventCountNotifier (QObject *parent = Q_NULLPTR);
	
	int getUnreadMessageCount () const;
	int getMissedCallCount () const;
	int getEventCount () const;
signals:
	void eventCountChanged ();

protected:
	virtual void notifyEventCount (int n) = 0;
	
private:
	
	void internalNotifyEventCount ();
};

#endif // ABSTRACT_EVENT_COUNT_NOTIFIER_H_
