/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef _CONFERENCE_INFO_MAP_MODEL_H_
#define _CONFERENCE_INFO_MAP_MODEL_H_

#include <linphone++/linphone.hh>
#include <QDate>

#include "app/proxyModel/ProxyAbstractMapModel.hpp"
#include "app/proxyModel/ProxyListModel.hpp"
#include "app/proxyModel/SortFilterAbstractProxyModel.hpp"

// =============================================================================

class ConferenceInfoMapModel : public ProxyAbstractMapModel<QDate,SortFilterAbstractProxyModel<ProxyListModel>*>  {
	Q_OBJECT
	
public:
	ConferenceInfoMapModel (QObject *parent = Q_NULLPTR);
signals:
	void filterTypeChanged(int filterType);
	
};
Q_DECLARE_METATYPE(ConferenceInfoMapModel*)
#endif
