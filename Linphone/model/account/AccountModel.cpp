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

#include "AccountModel.hpp"

#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include <QDebug>
#include <QUrl>

DEFINE_ABSTRACT_OBJECT(AccountModel)

AccountModel::AccountModel(const std::shared_ptr<linphone::Account> &account, QObject *parent)
    : ::Listener<linphone::Account, linphone::AccountListener>(account, parent) {
	mustBeInLinphoneThread(getClassName());
	connect(CoreModel::getInstance().get(), &CoreModel::defaultAccountChanged, this,
	        &AccountModel::onDefaultAccountChanged);

	// Hack because Account doesn't provide callbacks on updated data
	connect(this, &AccountModel::defaultAccountChanged, this, [this]() {
		emit pictureUriChanged(Utils::coreStringToAppString(mMonitor->getParams()->getPictureUri()));
		emit displayNameChanged(
		    Utils::coreStringToAppString(mMonitor->getParams()->getIdentityAddress()->getDisplayName()));
	});

	connect(CoreModel::getInstance().get(), &CoreModel::unreadNotificationsChanged, this, [this]() {
		emit unreadNotificationsChanged(0 /*mMonitor->getUnreadChatMessageCount()*/,
		                                mMonitor->getMissedCallsCount()); // TODO
	});
}

AccountModel::~AccountModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void AccountModel::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                              linphone::RegistrationState state,
                                              const std::string &message) {
	emit registrationStateChanged(account, state, message);
}

void AccountModel::onMessageWaitingIndicationChanged(
    const std::shared_ptr<linphone::Account> &account,
    const std::shared_ptr<const linphone::MessageWaitingIndication> &mwi) {
	for (auto summary : mwi->getSummaries()) {
		qInfo() << "[MWI] new" << summary->getNbNew() << "new+urgent" << summary->getNbNewUrgent() << "old"
		        << summary->getNbOld() << "old+urgent" << summary->getNbOldUrgent();
		auto userData = getUserData(account);
		if (!userData) userData = std::make_shared<AccountUserData>();
		userData->voicemailCount = summary->getNbNew();
		setUserData(account, userData);
		emit voicemailCountChanged(summary->getNbNew());
	}
}

void AccountModel::setPictureUri(QString uri) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto oldPictureUri = Utils::coreStringToAppString(params->getPictureUri());
	if (!oldPictureUri.isEmpty()) {
		QString appPrefix = QStringLiteral("image://%1/").arg(AvatarProvider::ProviderId);
		if (oldPictureUri.startsWith(appPrefix)) {
			oldPictureUri = Paths::getAvatarsDirPath() + oldPictureUri.mid(appPrefix.length());
		}
		QFile oldPicture(oldPictureUri);
		if (!oldPicture.remove()) qWarning() << log().arg("Cannot delete old avatar file at " + oldPictureUri);
	}
	params->setPictureUri(Utils::appStringToCoreString(uri));
	mMonitor->setParams(params);
	// Hack because Account doesn't provide callbacks on updated data
	// emit pictureUriChanged(uri);
	auto core = CoreModel::getInstance()->getCore();
	emit CoreModel::getInstance()->defaultAccountChanged(core, core->getDefaultAccount());
}

void AccountModel::onDefaultAccountChanged() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	emit defaultAccountChanged(CoreModel::getInstance()->getCore()->getDefaultAccount() == mMonitor);
}

void AccountModel::setDefault() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto core = CoreModel::getInstance()->getCore();
	core->setDefaultAccount(mMonitor);
}

void AccountModel::removeAccount() {
	CoreModel::getInstance()->getCore()->removeAccount(mMonitor);
	removeUserData(mMonitor);
	emit removed();
}

void AccountModel::resetMissedCallsCount() {
	mMonitor->resetMissedCallsCount();
	emit unreadNotificationsChanged(0 /*mMonitor->getUnreadChatMessageCount()*/,
	                                mMonitor->getMissedCallsCount()); // TODO
}

void AccountModel::refreshUnreadNotifications() {
	emit unreadNotificationsChanged(0 /*mMonitor->getUnreadChatMessageCount()*/,
	                                mMonitor->getMissedCallsCount()); // TODO
}

int AccountModel::getMissedCallsCount() const {
	return mMonitor->getMissedCallsCount();
}

int AccountModel::getUnreadMessagesCount() const {
	return mMonitor->getUnreadChatMessageCount();
}

void AccountModel::setDisplayName(QString displayName) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = params->getIdentityAddress()->clone();
	address->setDisplayName(Utils::appStringToCoreString(displayName));
	params->setIdentityAddress(address);
	mMonitor->setParams(params);
	// Hack because Account doesn't provide callbacks on updated data
	// emit displayNameChanged(displayName);
	auto core = CoreModel::getInstance()->getCore();
	emit CoreModel::getInstance()->defaultAccountChanged(core, core->getDefaultAccount());
}

void AccountModel::setDialPlan(int index) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	std::string callingCode = "";
	std::string countryCode = "";
	if (index != -1) {
		auto plans = linphone::Factory::get()->getDialPlans();
		std::vector<std::shared_ptr<linphone::DialPlan>> vectorPlans(plans.begin(), plans.end());
		auto plan = vectorPlans[index];
		callingCode = plan->getCountryCallingCode();
		countryCode = plan->getIsoCountryCode();
	}
	auto params = mMonitor->getParams()->clone();
	params->setInternationalPrefix(callingCode);
	params->setInternationalPrefixIsoCountryCode(countryCode);
	mMonitor->setParams(params);
	emit dialPlanChanged(index);
}

void AccountModel::setRegisterEnabled(bool enabled) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->enableRegister(enabled);
	mMonitor->setParams(params);
	emit registerEnabledChanged(enabled);
}

std::string AccountModel::getConfigAccountUiSection() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return "ui_" + mMonitor->getParams()->getIdentityAddress()->asStringUriOnly();
}

bool AccountModel::getNotificationsAllowed() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mMonitor->getCore()->getConfig()->getBool(getConfigAccountUiSection(), "notifications_allowed", true);
}

void AccountModel::setNotificationsAllowed(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mMonitor->getCore()->getConfig()->setBool(getConfigAccountUiSection(), "notifications_allowed", value);
	emit notificationsAllowedChanged(value);
}

void AccountModel::setMwiServerAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(value));
	if (address) {
		params->setMwiServerAddress(address);
		mMonitor->setParams(params);
		emit mwiServerAddressChanged(value);
	} else qWarning() << "Unable to set MWI address, failed creating address from" << value;
}

void AccountModel::setTransport(linphone::TransportType value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->setTransport(value);
	mMonitor->setParams(params);
	emit transportChanged(value);
}

void AccountModel::setServerAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(value));
	if (address) {
		params->setServerAddress(address);
		mMonitor->setParams(params);
		emit serverAddressChanged(value);
	} else qWarning() << "Unable to set ServerAddress, failed creating address from" << value;
}

void AccountModel::setOutboundProxyEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->enableOutboundProxy(value);
	mMonitor->setParams(params);
	emit outboundProxyEnabledChanged(value);
}

void AccountModel::setStunServer(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto policy = params->getNatPolicy();
	if (!policy) policy = mMonitor->getCore()->createNatPolicy();
	policy->setStunServer(Utils::appStringToCoreString(value));
	params->setNatPolicy(policy);
	mMonitor->setParams(params);
	emit stunServerChanged(value);
}

void AccountModel::setIceEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto policy = params->getNatPolicy();
	if (!policy) policy = mMonitor->getCore()->createNatPolicy();
	policy->enableIce(value);
	params->setNatPolicy(policy);
	mMonitor->setParams(params);
	emit iceEnabledChanged(value);
}

void AccountModel::setAvpfEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->setAvpfMode(value ? linphone::AVPFMode::Enabled : linphone::AVPFMode::Disabled);
	mMonitor->setParams(params);
	emit avpfEnabledChanged(value);
}

void AccountModel::setBundleModeEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->enableRtpBundle(value);
	mMonitor->setParams(params);
	emit bundleModeEnabledChanged(value);
}

void AccountModel::setExpire(int value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->setExpires(value);
	mMonitor->setParams(params);
	emit expireChanged(value);
}

void AccountModel::setConferenceFactoryAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(value));
	if (address) {
		params->setConferenceFactoryAddress(address);
		mMonitor->setParams(params);
		emit conferenceFactoryAddressChanged(value);
	} else qWarning() << "Unable to set ConferenceFactoryAddress address, failed creating address from" << value;
}

void AccountModel::setAudioVideoConferenceFactoryAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(value));
	if (address) {
		params->setAudioVideoConferenceFactoryAddress(address);
		mMonitor->setParams(params);
		emit audioVideoConferenceFactoryAddressChanged(value);
	} else
		qWarning() << "Unable to set AudioVideoConferenceFactoryAddress address, failed creating address from" << value;
}

void AccountModel::setLimeServerUrl(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(value));
	params->setLimeServerUrl(Utils::appStringToCoreString(value));
	mMonitor->setParams(params);
	emit limeServerUrlChanged(value);
}

QString AccountModel::dialPlanAsString(const std::shared_ptr<linphone::DialPlan> &dialPlan) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(dialPlan->getFlag() + " " + dialPlan->getCountry() + " | +" +
	                                    dialPlan->getCountryCallingCode());
}

int AccountModel::getVoicemailCount() {
	auto userData = getUserData(mMonitor);
	if (userData) return userData->voicemailCount;
	else return 0;
}

// UserData (see hpp for explanations)

static QMap<const std::shared_ptr<linphone::Account>, std::shared_ptr<AccountUserData>> userDataMap;

void AccountModel::setUserData(const std::shared_ptr<linphone::Account> &account,
                               std::shared_ptr<AccountUserData> &data) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	userDataMap[account] = data;
}
std::shared_ptr<AccountUserData> AccountModel::getUserData(const std::shared_ptr<linphone::Account> &account) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	if (userDataMap.contains(account)) return userDataMap.value(account);
	else return nullptr;
}
void AccountModel::removeUserData(const std::shared_ptr<linphone::Account> &account) {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
	userDataMap.remove(account);
}
