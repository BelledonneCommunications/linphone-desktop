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

#include "../proxy/LimitProxy.hpp"
#include "PayloadTypeList.hpp"
#include "tool/AbstractObject.hpp"

// =============================================================================

class PayloadTypeProxy : public LimitProxy, public AbstractObject {
	Q_OBJECT

public:
	enum PayloadTypeProxyFiltering {
		All = 0,
		Audio = 2,
		Video = 4,
		Text = 8,
		Downloadable = 16,
		NotDownloadable = 32
	};
	Q_ENUMS(PayloadTypeProxyFiltering)

	DECLARE_SORTFILTER_CLASS()

	Q_INVOKABLE void reload();

	PayloadTypeProxy(QObject *parent = Q_NULLPTR);
	~PayloadTypeProxy();

protected:
	QSharedPointer<PayloadTypeList> mPayloadTypeList;

	DECLARE_ABSTRACT_OBJECT
};

#endif
