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

#ifndef TUNNEL_CONFIG_MODEL_H_
#define TUNNEL_CONFIG_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QString>

class TunnelConfigModel : public QObject {
    Q_OBJECT

public:
    TunnelConfigModel (std::shared_ptr<linphone::TunnelConfig> config, QObject *parent = nullptr);
	
	Q_PROPERTY(QString host READ getHost WRITE setHost NOTIFY hostChanged)
	Q_PROPERTY(QString host2 READ getHost2 WRITE setHost2 NOTIFY host2Changed)
	Q_PROPERTY(int port READ getPort WRITE setPort NOTIFY portChanged)
	Q_PROPERTY(int port2 READ getPort2 WRITE setPort2 NOTIFY port2Changed)
	Q_PROPERTY(int remoteUdpMirrorPort READ getRemoteUdpMirrorPort WRITE setRemoteUdpMirrorPort NOTIFY remoteUdpMirrorPortChanged)
	Q_PROPERTY(int delay READ getDelay WRITE setDelay NOTIFY delayChanged)
	
	QString getHost() const;
	QString getHost2() const;
	int getPort() const;
	int getPort2() const;
	int getRemoteUdpMirrorPort() const;
	int getDelay() const;
	
	void setHost(const QString& host);
	void setHost2(const QString& host);
	void setPort(const int& port);
	void setPort2(const int& port);
	void setRemoteUdpMirrorPort(const int& port);
	void setDelay(const int& delay);
	
	std::shared_ptr<linphone::TunnelConfig>  getTunnelConfig();
	
signals:
	void hostChanged();
	void host2Changed();
	void portChanged();
	void port2Changed();
	void remoteUdpMirrorPortChanged();
	void delayChanged();

private:

    std::shared_ptr<linphone::TunnelConfig> mTunnelConfig;
	
};

Q_DECLARE_METATYPE(QSharedPointer<TunnelConfigModel>)

#endif // TUNNEL_CONFIG_MODEL
