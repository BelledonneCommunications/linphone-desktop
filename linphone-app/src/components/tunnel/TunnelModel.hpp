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

#ifndef TUNNEL_MODEL_H_
#define TUNNEL_MODEL_H_

#include "utils/LinphoneEnums.hpp"

#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

class TunnelConfigListModel;
class TunnelConfigProxyModel;
class TunnelConfigModel;

class TunnelModel : public QObject {
    Q_OBJECT

public:
    TunnelModel (std::shared_ptr<linphone::Tunnel> linphoneTunnel, QObject *parent = nullptr);


	Q_PROPERTY(QString domain READ getDomain WRITE setDomain NOTIFY domainChanged)
	Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY usernameChanged)
	Q_PROPERTY(bool dualModeEnabled READ getDualModeEnabled WRITE setDualModeEnabled NOTIFY dualModeEnabledChanged)
	Q_PROPERTY(LinphoneEnums::TunnelMode mode READ getMode WRITE setMode NOTIFY modeChanged)
	Q_PROPERTY(bool sipEnabled READ getSipEnabled WRITE setSipEnabled NOTIFY sipEnabledChanged)
	
	QString getDomain() const;
	QString getUsername() const;
	bool getDualModeEnabled() const;
	LinphoneEnums::TunnelMode getMode() const;
	bool getSipEnabled() const;
	
	void setDomain(const QString& data);
	void setUsername(const QString& data);
	void setDualModeEnabled(const bool& data);
	void setMode(const LinphoneEnums::TunnelMode& data);
	void setSipEnabled(const bool& data);
	
	std::shared_ptr<linphone::Tunnel>  getTunnel();
	Q_INVOKABLE TunnelConfigProxyModel * getTunnelProxyConfigs();
	std::shared_ptr<TunnelConfigListModel> getTunnelConfigs();
	Q_INVOKABLE bool apply();
	Q_INVOKABLE void addTunnelConfig();
	Q_INVOKABLE void removeTunnelConfig(TunnelConfigModel * model);
	Q_INVOKABLE bool getActivated()const;
	Q_INVOKABLE void setHttpProxy(const QString& host, int port, const QString& username, const QString& passwd);
	
signals:
	void domainChanged();
	void usernameChanged();
	void sipAddressChanged();
	void dualModeEnabledChanged();
	void modeChanged();
	void sipEnabledChanged();
private:

    std::shared_ptr<linphone::Tunnel> mTunnel;
	std::shared_ptr<TunnelConfigListModel> mTunnelConfigs;
};

Q_DECLARE_METATYPE(std::shared_ptr<TunnelModel>);

#endif // TUNNEL_MODEL_H_
