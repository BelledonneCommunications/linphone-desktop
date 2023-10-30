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

#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include <QFont>
#include <QObject>
#include <QVariantMap>
#include <linphone++/linphone.hh>

#include "tool/AbstractObject.hpp"

class SettingsModel : public QObject, public AbstractObject {
	Q_OBJECT
public:
	SettingsModel(QObject *parent = Q_NULLPTR);
	virtual ~SettingsModel();

	bool isReadOnly(const std::string &section, const std::string &name) const;
	std::string
	getEntryFullName(const std::string &section,
	                 const std::string &name) const; // Return the full name of the entry : 'name/readonly' or 'name'

	static const std::string UiSection;

	std::shared_ptr<linphone::Config> mConfig;

private:
	DECLARE_ABSTRACT_OBJECT
};
#endif // SETTINGS_MODEL_H_
