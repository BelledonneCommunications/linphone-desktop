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

#ifndef CALL_HISTORY_LIST_MODEL_H_
#define CALL_HISTORY_LIST_MODEL_H_

#include <QSharedPointer>
#include <linphone++/linphone.hh>
#include "app/proxyModel/ProxyListModel.hpp"


class CallHistoryModel;
// =============================================================================

class CallHistoryListModel : public ProxyListModel {
  Q_OBJECT
public:
	
	Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    
    CallHistoryListModel (QObject *parent = Q_NULLPTR);
    virtual ~CallHistoryListModel();
    
    void reload();
    void add(const std::list<std::shared_ptr<linphone::CallLog>>& callLog);
    void onCallLogUpdated(const std::shared_ptr<linphone::CallLog> &call);
    void onSelectedChanged(bool selected, CallHistoryModel * model);
	void onSelectOnlyRequested();
	void onHasBeenRemoved();
signals:
	void countChanged();
	void selectedChanged(CallHistoryModel * model);
	void lastCallDateChanged();
private:
	QHash<QString, QSharedPointer<CallHistoryModel>> mCalls;
};

#endif
