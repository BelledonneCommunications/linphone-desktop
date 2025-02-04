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
	connect(CoreModel::getInstance().get(), &CoreModel::accountRemoved, this,
	        [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account) {
		        if (account == mMonitor) {
			        if (mToRemove && account->getState() == linphone::RegistrationState::None) {
				        lInfo() << log().arg("Disabled account removed");
				        auto authInfo = mMonitor->findAuthInfo();
				        if (authInfo) {
					        lInfo() << log().arg("Removing authinfo for disabled account");
					        CoreModel::getInstance()->getCore()->removeAuthInfo(authInfo);
				        }
				        removeUserData(mMonitor);
				        emit removed();
			        }
		        }
	        });
}

AccountModel::~AccountModel() {
	mustBeInLinphoneThread("~" + getClassName());
}

void AccountModel::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                              linphone::RegistrationState state,
                                              const std::string &message) {
	// Cleared and None are the last state on processes after being change. Check for accountRemoved for account that
	// was not registered.
	if (mToRemove && (state == linphone::RegistrationState::Cleared || state == linphone::RegistrationState::None)) {
		lInfo() << log().arg("Account removed on state [%1]").arg((int)state);
		auto authInfo = mMonitor->findAuthInfo();
		if (authInfo) {
			lInfo() << log().arg("Removing authinfo");
			CoreModel::getInstance()->getCore()->removeAuthInfo(authInfo);
		}
		removeUserData(mMonitor);
		emit removed();
	}
	emit registrationStateChanged(account, state, message);
}

void AccountModel::onMessageWaitingIndicationChanged(
    const std::shared_ptr<linphone::Account> &account,
    const std::shared_ptr<const linphone::MessageWaitingIndication> &mwi) {
	auto userData = getUserData(account);
	if (!userData) userData = std::make_shared<AccountUserData>();
	userData->showMwi = mwi->hasMessageWaiting();
	for (auto summary : mwi->getSummaries()) {
		qInfo() << "[MWI] new" << summary->getNbNew() << "new+urgent" << summary->getNbNewUrgent() << "old"
		        << summary->getNbOld() << "old+urgent" << summary->getNbOldUrgent();

		userData->voicemailCount = summary->getNbNew();
		emit voicemailCountChanged(summary->getNbNew());
	}
	setUserData(account, userData);
	emit showMwiChanged(mwi->hasMessageWaiting());
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
	auto core = CoreModel::getInstance()->getCore();
	auto params = mMonitor ? mMonitor->getParams() : nullptr;
	lInfo() << log()
	               .arg("Removing account [%1]")
	               .arg(params && params->getIdentityAddress()
	                        ? Utils::coreStringToAppString(params->getIdentityAddress()->asString())
	                        : "Null");
	mToRemove = true;
	if (mMonitor) core->removeAccount(mMonitor);
}

std::shared_ptr<linphone::Account> AccountModel::getAccount() const {
	return mMonitor;
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
	if (enabled) mMonitor->refreshRegister();
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

QString AccountModel::getMwiServerAddress() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto mwiAddress = mMonitor->getParams()->getMwiServerAddress();
	return mwiAddress ? Utils::coreStringToAppString(mwiAddress->asString()) : "";
}

void AccountModel::setMwiServerAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto address = value.isEmpty()
	                   ? nullptr
	                   : CoreModel::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(value), false);

	if (value.isEmpty() || address) {
		auto params = mMonitor->getParams();
		auto oldAddress = params->getMwiServerAddress();
		if (address != oldAddress && (!address || !address->weakEqual(oldAddress))) {
			auto newParams = params->clone();
			newParams->setMwiServerAddress(address);
			if (!mMonitor->setParams(newParams)) emit mwiServerAddressChanged(value);
		}
	} else qWarning() << "Unable to set MWI address, failed creating address from" << value;
}

linphone::TransportType AccountModel::getTransport() const {
	return mMonitor->getParams()->getTransport();
}

void AccountModel::setTransport(linphone::TransportType value, bool save) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	if (params->getServerAddress()) {
		auto addressClone = params->getServerAddress()->clone();
		addressClone->setTransport(value);
		params->setServerAddress(addressClone);
		if (save) mMonitor->setParams(params);
		emit transportChanged(value);
		emit serverAddressChanged(Utils::coreStringToAppString(addressClone->asString()));
	}
}

QString AccountModel::getServerAddress() const {
	if (mMonitor->getParams()->getServerAddress())
		return Utils::coreStringToAppString(mMonitor->getParams()->getServerAddress()->asString());
	else return "";
}

void AccountModel::setServerAddress(QString value, linphone::TransportType transport, bool save) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = CoreModel::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(value), false);
	if (address) {
		if (save) address->setTransport(transport);
		params->setServerAddress(address);
		if (save) mMonitor->setParams(params);
		emit serverAddressChanged(value);
		emit transportChanged(address->getTransport());
	} else qWarning() << "Unable to set ServerAddress, failed creating address from" << value;
}

bool AccountModel::getOutboundProxyEnabled() const {
	return mMonitor->getParams()->outboundProxyEnabled();
}

void AccountModel::setOutboundProxyEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->enableOutboundProxy(value);
	mMonitor->setParams(params);
	emit outboundProxyEnabledChanged(value);
}

QString AccountModel::getStunServer() const {
	auto policy = mMonitor->getParams()->getNatPolicy();
	if (policy) return Utils::coreStringToAppString(policy->getStunServer());
	else return QString();
}

void AccountModel::setStunServer(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto policy = params->getNatPolicy();
	if (!policy) policy = mMonitor->getCore()->createNatPolicy();
	policy->setStunServer(Utils::appStringToCoreString(value));
	policy->enableStun(!value.isEmpty());
	params->setNatPolicy(policy);
	mMonitor->setParams(params);
	emit stunServerChanged(value);
}

bool AccountModel::getIceEnabled() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto policy = mMonitor->getParams()->getNatPolicy();
	return policy && policy->iceEnabled();
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

bool AccountModel::getAvpfEnabled() const {
	return mMonitor->getParams()->getAvpfMode() == linphone::AVPFMode::Enabled;
}

void AccountModel::setAvpfEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->setAvpfMode(value ? linphone::AVPFMode::Enabled : linphone::AVPFMode::Disabled);
	mMonitor->setParams(params);
	emit avpfEnabledChanged(value);
}

bool AccountModel::getBundleModeEnabled() const {
	return mMonitor->getParams()->rtpBundleEnabled();
}

void AccountModel::setBundleModeEnabled(bool value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->enableRtpBundle(value);
	mMonitor->setParams(params);
	emit bundleModeEnabledChanged(value);
}

int AccountModel::getExpire() const {
	return mMonitor->getParams()->getExpires();
}

void AccountModel::setExpire(int value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	params->setExpires(value);
	mMonitor->setParams(params);
	emit expireChanged(value);
}

QString AccountModel::getConferenceFactoryAddress() const {
	auto confAddress = mMonitor->getParams()->getConferenceFactoryAddress();
	return confAddress ? Utils::coreStringToAppString(confAddress->asString()) : QString();
}

void AccountModel::setConferenceFactoryAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = value.isEmpty()
	                   ? nullptr
	                   : CoreModel::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(value), false);
	if (value.isEmpty() || address) {
		params->setConferenceFactoryAddress(address);
		mMonitor->setParams(params);
		emit conferenceFactoryAddressChanged(value);
	} else qWarning() << "Unable to set ConferenceFactoryAddress address, failed creating address from" << value;
}

QString AccountModel::getAudioVideoConferenceFactoryAddress() const {
	auto confAddress = mMonitor->getParams()->getAudioVideoConferenceFactoryAddress();
	return confAddress ? Utils::coreStringToAppString(confAddress->asString()) : QString();
}

void AccountModel::setAudioVideoConferenceFactoryAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = value.isEmpty()
	                   ? nullptr
	                   : CoreModel::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(value), false);
	if (value.isEmpty() || address) {
		params->setAudioVideoConferenceFactoryAddress(address);
		mMonitor->setParams(params);
		emit audioVideoConferenceFactoryAddressChanged(value);
	} else
		qWarning() << "Unable to set AudioVideoConferenceFactoryAddress address, failed creating address from" << value;
}

QString AccountModel::getLimeServerUrl() const {
	return Utils::coreStringToAppString(mMonitor->getParams()->getLimeServerUrl());
}

void AccountModel::setLimeServerUrl(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
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

bool AccountModel::getShowMwi() {
	auto userData = getUserData(mMonitor);
	if (userData) return userData->showMwi;
	else return false;
}

void AccountModel::setVoicemailAddress(QString value) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	auto params = mMonitor->getParams()->clone();
	auto address = value.isEmpty()
	                   ? nullptr
	                   : CoreModel::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(value), false);
	if (value.isEmpty() || address) {
		params->setVoicemailAddress(address);
		mMonitor->setParams(params);
		emit voicemailAddressChanged(value);
	} else qWarning() << "Unable to set VoicemailAddress, failed creating address from" << value;
}

QString AccountModel::getVoicemailAddress() const {
	auto addr = mMonitor->getParams()->getVoicemailAddress();
	return addr ? Utils::coreStringToAppString(addr->asString()) : "";
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
