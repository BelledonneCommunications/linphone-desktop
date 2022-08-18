/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#ifndef _CONFERENCE_INFO_LIST_MODEL_H_
#define _CONFERENCE_INFO_LIST_MODEL_H_

#include <linphone++/linphone.hh>
#include <QDate>

#include "app/proxyModel/ProxyAbstractListModel.hpp"
#include "app/proxyModel/ProxyListModel.hpp"
#include "app/proxyModel/SortFilterAbstractProxyModel.hpp"

// =============================================================================

class ConferenceInfoListModel : public ProxyListModel  {
	Q_OBJECT
	
public:
	ConferenceInfoListModel (QObject *parent = Q_NULLPTR);
	void add(const std::shared_ptr<linphone::ConferenceInfo> & conferenceInfo, const bool& sendEvents = true);
	
	QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
signals:
	void filterTypeChanged(int filterType);
	
};
Q_DECLARE_METATYPE(ConferenceInfoListModel*)
#endif
