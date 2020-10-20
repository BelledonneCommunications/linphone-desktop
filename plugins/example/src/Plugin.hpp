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
#ifndef PLUGIN_HPP
#define PLUGIN_HPP

#include <QObject>
#include <QtPlugin>
#include <LinphoneApp/LinphonePlugin.hpp>
#include <LinphoneApp/PluginDataAPI.hpp>
#include <linphone++/core.hh>
//-----------------------------

class QPluginLoader;

class Plugin : public QObject,  public LinphonePlugin
{
	Q_OBJECT
	Q_PLUGIN_METADATA(IID LinphonePlugin_iid FILE "PluginMetaData.json")
	Q_INTERFACES(LinphonePlugin)
public:
	Plugin(){}
	virtual QString getGUIDescriptionToJson() const;
	virtual PluginDataAPI * createInstance(void* core, QPluginLoader * pluginLoader);
};

#endif
