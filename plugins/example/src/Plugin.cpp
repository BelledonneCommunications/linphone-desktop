/******************************************************************************
*
*  Copyright (c) 2017-2020 Belledonne Communications SARL.
* 
*  This file is part of linphone-desktop
*  (see https://www.linphone.org).
* 
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
* 
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
* 
*  You should have received a copy of the GNU General Public License
*  along with this program. If not, see <http://www.gnu.org/licenses/>.
*
*******************************************************************************/
#include "Plugin.hpp"
#include <QJsonDocument>
#include <QJsonArray>

#include "DataAPI.hpp"
#include "NetworkAPI.hpp"

QString Plugin::getGUIDescriptionToJson()const{
	QJsonObject description;
	description["pluginTitle"] = "Plugin Example";
	description["pluginDescription"] = "This is a test plugin to import an address book from an URL";

	QJsonObject field;
	QJsonArray fields;
	field["placeholder"] = "SIP Domain";
	field["fieldId"] = "SIP_Domain";
	field["defaultData"] = "";	// Set by the Data instance from Core
	field["type"] = 1;
	field["capability"] = PluginDataAPI::CONTACTS;
	fields.append(field);

	field = QJsonObject();
	field["placeholder"] = "URL";
	field["fieldId"] = "URL";
	field["defaultData"] = "";
	field["type"] = 1;
	field["capability"] = PluginDataAPI::CONTACTS;
	fields.append(field);

	field = QJsonObject();
	field["placeholder"] = "Username";
	field["fieldId"] = "Username";
	field["defaultData"] = "username@domain.com";
	field["type"] = 1;
	field["capability"] = PluginDataAPI::CONTACTS;
	fields.append(field);

	field = QJsonObject();
	field["placeholder"] = "Password";
	field["fieldId"] = "Password";
	field["defaultData"] = "This is a pass";
	field["type"] = 1;
	field["hiddenText"] = true;
	field["capability"] = PluginDataAPI::CONTACTS;
	fields.append(field);

	description["fields"] = fields;
	
	QJsonDocument document(description);
	return document.toJson();
}

PluginDataAPI * Plugin::createInstance(void * core, QPluginLoader *pluginLoader){
	return new DataAPI(this, core, pluginLoader);
}
