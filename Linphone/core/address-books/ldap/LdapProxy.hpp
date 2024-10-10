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

#ifndef LDAP_PROXY_H_
#define LDAP_PROXY_H_

#include "../../proxy/LimitProxy.hpp"
#include "LdapList.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class LdapProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT

public:
	DECLARE_SORTFILTER_CLASS()

	LdapProxy(QObject *parent = Q_NULLPTR);
	~LdapProxy();

	Q_INVOKABLE void removeAllEntries();
	Q_INVOKABLE void removeEntriesWithFilter();
	Q_INVOKABLE void updateView();

signals:
	void filterTextChanged();

protected:
	QSharedPointer<LdapList> mLdapList;

	DECLARE_ABSTRACT_OBJECT
};

#endif
