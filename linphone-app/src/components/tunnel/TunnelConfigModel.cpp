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

#include <QQmlApplicationEngine>

#include "app/App.hpp"

#include "TunnelConfigModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

using namespace std;

TunnelConfigModel::TunnelConfigModel (shared_ptr<linphone::TunnelConfig> tunnelConfig, QObject *parent) : QObject(parent) {
  mTunnelConfig = tunnelConfig;
}

// -----------------------------------------------------------------------------

QString TunnelConfigModel::getHost() const{
	return Utils::coreStringToAppString(mTunnelConfig->getHost());
}

QString TunnelConfigModel::getHost2() const{
	return Utils::coreStringToAppString(mTunnelConfig->getHost2());
}

int TunnelConfigModel::getPort() const{
	return mTunnelConfig->getPort();
}

int TunnelConfigModel::getPort2() const{
	return mTunnelConfig->getPort2();
}

int TunnelConfigModel::getRemoteUdpMirrorPort() const{
	return mTunnelConfig->getRemoteUdpMirrorPort();
}

int TunnelConfigModel::getDelay() const{
	return mTunnelConfig->getDelay();
}

void TunnelConfigModel::setHost(const QString& host){
	mTunnelConfig->setHost(Utils::appStringToCoreString(host));
	emit hostChanged();
}

void TunnelConfigModel::setHost2(const QString& host){
	mTunnelConfig->setHost2(Utils::appStringToCoreString(host));
	emit host2Changed();
}

void TunnelConfigModel::setPort(const int& port){
	mTunnelConfig->setPort(port);
	emit portChanged();
}

void TunnelConfigModel::setPort2(const int& port){
	mTunnelConfig->setPort2(port);
	emit port2Changed();
}

void TunnelConfigModel::setRemoteUdpMirrorPort(const int& port){
	mTunnelConfig->setRemoteUdpMirrorPort(port);
	emit remoteUdpMirrorPortChanged();
}

void TunnelConfigModel::setDelay(const int& delay){
	mTunnelConfig->setDelay(delay);
	emit delayChanged();
}

std::shared_ptr<linphone::TunnelConfig>  TunnelConfigModel::getTunnelConfig(){
	return mTunnelConfig;
}
