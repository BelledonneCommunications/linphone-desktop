/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#ifndef EMOJIS_SETTINGS_MODEL_H_
#define EMOJIS_SETTINGS_MODEL_H_

#include <QObject>
#include <QList>

// =============================================================================

class EmojisSettingsModel : public QObject {
	Q_OBJECT
	Q_PROPERTY(QList<int> lastUseds READ getLastUseds WRITE setLastUseds NOTIFY lastUsedsChanged)
	
public:
	EmojisSettingsModel (QObject *parent = Q_NULLPTR);
	virtual ~EmojisSettingsModel ();
	Q_INVOKABLE void addLastUsed(const int& code);
	Q_INVOKABLE void clear();
	QList<int> getLastUseds() const;
	void setLastUseds(QList<int> LastUsedCodes);
	int mMaxLastUseds = 15;

signals:
	void lastUsedsChanged();
};


#endif
