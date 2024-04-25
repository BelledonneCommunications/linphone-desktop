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

#ifndef SCREEN_LIST_H_
#define SCREEN_LIST_H_

#include "core/proxy/AbstractListProxy.hpp"

#include <QScreen>

class ScreenList : public AbstractListProxy<QVariantMap> {

	Q_OBJECT

public:
	enum Mode { SCREENS = 0, WINDOWS = 1 };
	Q_ENUM(Mode)

	ScreenList(QObject *parent = Q_NULLPTR);
	virtual ~ScreenList();

	ScreenList::Mode getMode() const;
	void setMode(ScreenList::Mode);

	void update();

	Mode mMode = WINDOWS;

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
signals:
	void modeChanged();
};

#endif
