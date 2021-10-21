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

#include "TunnelModel.hpp"
#include "utils/Utils.hpp"

#include "components/Components.hpp"

// =============================================================================

using namespace std;

TunnelModel::TunnelModel (shared_ptr<linphone::Tunnel> tunnel, QObject *parent) : QObject(parent) {
	App::getInstance()->getEngine()->setObjectOwnership(this, QQmlEngine::CppOwnership);// Avoid QML to destroy it when passing by Q_INVOKABLE
	mTunnel = tunnel;
	if(mTunnel){
		mTunnelConfigs = std::make_shared<TunnelConfigListModel>(mTunnel);
	}
}

// -----------------------------------------------------------------------------

QString TunnelModel::getDomain() const{
	return Utils::coreStringToAppString(mTunnel->getDomain());
}

QString TunnelModel::getUsername() const{
	return Utils::coreStringToAppString(mTunnel->getUsername());
}

bool TunnelModel::getDualModeEnabled() const{
	return mTunnel->dualModeEnabled();
}

LinphoneEnums::TunnelMode TunnelModel::getMode() const{
	return LinphoneEnums::fromLinphone(mTunnel->getMode());
}

bool TunnelModel::getSipEnabled() const{
	return mTunnel->sipEnabled();
}

// -----------------------------------------------------------------------------

void TunnelModel::setDomain(const QString& data){
	mTunnel->setDomain(Utils::appStringToCoreString(data));
	emit domainChanged();
}

void TunnelModel::setUsername(const QString& data){
	mTunnel->setUsername(Utils::appStringToCoreString(data));
	emit usernameChanged();
}

void TunnelModel::setDualModeEnabled(const bool& data){
	mTunnel->enableDualMode(data);
	emit dualModeEnabledChanged();
}

void TunnelModel::setMode(const LinphoneEnums::TunnelMode& data){
	mTunnel->setMode(LinphoneEnums::toLinphone(data));
	emit modeChanged();
}

void TunnelModel::setSipEnabled(const bool& data){
	mTunnel->enableSip(data);
	emit sipEnabledChanged();
}

// -----------------------------------------------------------------------------

std::shared_ptr<linphone::Tunnel>  TunnelModel::getTunnel(){
	return mTunnel;
}

TunnelConfigProxyModel * TunnelModel::getTunnelProxyConfigs(){
	TunnelConfigProxyModel * configs = new TunnelConfigProxyModel();
	configs->setTunnel(this);
	return configs;
}

std::shared_ptr<TunnelConfigListModel> TunnelModel::getTunnelConfigs(){
	return mTunnelConfigs;
}

bool TunnelModel::apply(){
	return mTunnelConfigs->apply(mTunnel);
}

void TunnelModel::addTunnelConfig(){
	mTunnelConfigs->addTunnelConfig();
}

void TunnelModel::removeTunnelConfig(TunnelConfigModel * model){
	mTunnelConfigs->removeTunnelConfig(mTunnel, model);
}

bool TunnelModel::getActivated()const{
	if(mTunnel)
		return mTunnel->getActivated();
	else
		return false;
}

void TunnelModel::setHttpProxy(const QString& host, int port, const QString& username, const QString& passwd){
	mTunnel->setHttpProxy(Utils::appStringToCoreString(host), port, Utils::appStringToCoreString(username), Utils::appStringToCoreString(passwd));
}