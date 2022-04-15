/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef TUNNEL_CONFIG_LIST_MODEL_H_
#define TUNNEL_CONFIG_LIST_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include "app/proxyModel/ProxyListModel.hpp"

class TunnelConfigModel;

class TunnelConfigListModel : public ProxyListModel {
	Q_OBJECT
	
public:
	TunnelConfigListModel (std::shared_ptr<linphone::Tunnel> tunnel, QObject *parent = nullptr);
	
	void updateTunnelConfigs(std::shared_ptr<linphone::Tunnel> tunnel);
	bool apply(std::shared_ptr<linphone::Tunnel> tunnel);
	void addTunnelConfig();
	void removeTunnelConfig(std::shared_ptr<linphone::Tunnel> tunnel, TunnelConfigModel * model);
	
};

Q_DECLARE_METATYPE(QSharedPointer<TunnelConfigListModel>)

#endif // TUNNEL_CONFIG_LIST_MODEL_H_
