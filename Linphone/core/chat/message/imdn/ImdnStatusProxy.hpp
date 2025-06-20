
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

#ifndef IMDN_STATUS_PROXY_H_
#define IMDN_STATUS_PROXY_H_

#include "core/chat/message/ChatMessageCore.hpp"
#include "core/proxy/LimitProxy.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class ImdnStatusList;

class ImdnStatusProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(
	    QList<ImdnStatus> imdnStatusList READ getImdnStatusList WRITE setImdnStatusList NOTIFY imdnStatusListChanged)
	Q_PROPERTY(LinphoneEnums::ChatMessageState filter READ getFilter WRITE setFilter NOTIFY filterChanged)

public:
	ImdnStatusProxy(QObject *parent = Q_NULLPTR);
	~ImdnStatusProxy();

	QList<ImdnStatus> getImdnStatusList();
	void setImdnStatusList(QList<ImdnStatus> imdnStatusList);

	LinphoneEnums::ChatMessageState getFilter() const;
	void setFilter(LinphoneEnums::ChatMessageState filter);

	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;

signals:
	void imdnStatusListChanged();
	void filterChanged();

protected:
	LinphoneEnums::ChatMessageState mFilter;
	QSharedPointer<ImdnStatusList> mList;
	DECLARE_ABSTRACT_OBJECT
};

#endif
