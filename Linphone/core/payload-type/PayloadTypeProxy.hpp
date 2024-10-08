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

#ifndef PAYLOAD_TYPE_PROXY_H_
#define PAYLOAD_TYPE_PROXY_H_

#include "../proxy/SortFilterProxy.hpp"
#include "PayloadTypeGui.hpp"
#include "PayloadTypeList.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class PayloadTypeProxy : public SortFilterProxy, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(PayloadTypeCore::Family family MEMBER mFamily)

public:
	PayloadTypeProxy(QObject *parent = Q_NULLPTR);
	~PayloadTypeProxy();

protected:
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

	PayloadTypeCore::Family mFamily;
	QSharedPointer<PayloadTypeList> mPayloadTypeList;

	DECLARE_ABSTRACT_OBJECT
};

#endif
