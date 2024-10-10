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

#ifndef SCREEN_PROXY_H_
#define SCREEN_PROXY_H_

#include "ScreenList.hpp"
#include "core/proxy/LimitProxy.hpp"
// =============================================================================

class QWindow;

class ScreenProxy : public LimitProxy {
	class ScreenModelFilter;

	Q_OBJECT
	Q_PROPERTY(ScreenList::Mode mode READ getMode WRITE setMode NOTIFY modeChanged)
public:
	DECLARE_SORTFILTER_CLASS()
	ScreenProxy(QObject *parent = Q_NULLPTR);

	ScreenList::Mode getMode() const;
	void setMode(ScreenList::Mode);

	Q_INVOKABLE void update();
signals:
	void modeChanged();
};

#endif
