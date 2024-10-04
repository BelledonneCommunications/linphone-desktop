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

#include "AccountCore.hpp"
#include "core/App.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QHostInfo>

DEFINE_ABSTRACT_OBJECT(AccountCore)

QSharedPointer<AccountCore> AccountCore::create(const std::shared_ptr<linphone::Account> &account) {
	auto model = QSharedPointer<AccountCore>(new AccountCore(account), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

AccountCore::AccountCore(const std::shared_ptr<linphone::Account> &account) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	// Should be call from model Thread
	mustBeInLinphoneThread(getClassName());
	// Init data
	auto address = account->getContactAddress();
	mContactAddress = address ? Utils::coreStringToAppString(account->getContactAddress()->asStringUriOnly()) : "";
	auto params = account->getParams();
	auto identityAddress = params->getIdentityAddress();
	mIdentityAddress = identityAddress ? Utils::coreStringToAppString(identityAddress->asStringUriOnly()) : "";
	mPictureUri = Utils::coreStringToAppString(params->getPictureUri());
	mRegistrationState = LinphoneEnums::fromLinphone(account->getState());
	mIsDefaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount() == account;
	// mUnreadNotifications = account->getUnreadChatMessageCount() + account->getMissedCallsCount();	// TODO
	mUnreadNotifications = account->getMissedCallsCount();
	mDisplayName = Utils::coreStringToAppString(identityAddress->getDisplayName());
	if (mDisplayName.isEmpty()) {
		mDisplayName = ToolModel::getDisplayName(mIdentityAddress);
	}
	mRegisterEnabled = params->registerEnabled();
	mMwiServerAddress =
	    params->getMwiServerAddress() ? Utils::coreStringToAppString(params->getMwiServerAddress()->asString()) : "";
	mTransports << "TCP"
	            << "UDP"
	            << "TLS"
	            << "DTLS";
	mTransport = LinphoneEnums::toString(LinphoneEnums::fromLinphone(params->getTransport()));
	mServerAddress =
	    params->getServerAddress() ? Utils::coreStringToAppString(params->getServerAddress()->asString()) : "";
	mOutboundProxyEnabled = params->outboundProxyEnabled();
	auto policy = params->getNatPolicy() ? params->getNatPolicy() : account->getCore()->createNatPolicy();
	mStunServer = Utils::coreStringToAppString(policy->getStunServer());
	mIceEnabled = policy->iceEnabled();
	mAvpfEnabled = account->avpfEnabled();
	mBundleModeEnabled = params->rtpBundleEnabled();
	mExpire = params->getExpires();
	mConferenceFactoryAddress = params->getConferenceFactoryAddress()
	                                ? Utils::coreStringToAppString(params->getConferenceFactoryAddress()->asString())
	                                : "";
	mAudioVideoConferenceFactoryAddress =
	    params->getAudioVideoConferenceFactoryAddress()
	        ? Utils::coreStringToAppString(params->getAudioVideoConferenceFactoryAddress()->asString())
	        : "";
	mLimeServerUrl = Utils::coreStringToAppString(params->getLimeServerUrl());

	// Add listener
	mAccountModel = Utils::makeQObject_ptr<AccountModel>(account); // OK
	mAccountModel->setSelf(mAccountModel);
	mNotificationsAllowed = mAccountModel->getNotificationsAllowed();
	mDialPlan = " ";
	mDialPlans << mDialPlan;
	for (auto dialPlan : linphone::Factory::get()->getDialPlans()) {
		mDialPlans << mAccountModel->dialPlanAsString(dialPlan);
		if (dialPlan->getCountryCallingCode() == account->getParams()->getInternationalPrefix()) {
			mDialPlan = mAccountModel->dialPlanAsString(dialPlan);
		}
	}

	INIT_CORE_MEMBER(VoicemailCount, mAccountModel)
}

AccountCore::~AccountCore() {
	mustBeInMainThread("~" + getClassName());
	emit mAccountModel->removeListener();
}

void AccountCore::setSelf(QSharedPointer<AccountCore> me) {
	mAccountModelConnection = QSharedPointer<SafeConnection<AccountCore, AccountModel>>(
	    new SafeConnection<AccountCore, AccountModel>(me, mAccountModel));
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::registrationStateChanged, [this](const std::shared_ptr<linphone::Account> &account,
	                                                    linphone::RegistrationState state, const std::string &message) {
		    mAccountModelConnection->invokeToCore(
		        [this, account, state, message]() { onRegistrationStateChanged(account, state, message); });
	    });
	// From Model
	mAccountModelConnection->makeConnectToModel(&AccountModel::defaultAccountChanged, [this](bool isDefault) {
		mAccountModelConnection->invokeToCore([this, isDefault]() { onDefaultAccountChanged(isDefault); });
	});

	mAccountModelConnection->makeConnectToModel(&AccountModel::pictureUriChanged, [this](QString uri) {
		mAccountModelConnection->invokeToCore([this, uri]() { onPictureUriChanged(uri); });
	});
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::unreadNotificationsChanged, [this](int unreadMessagesCount, int unreadCallsCount) {
		    mAccountModelConnection->invokeToCore([this, unreadMessagesCount, unreadCallsCount]() {
			    setUnreadNotifications(unreadMessagesCount + unreadCallsCount);
			    setUnreadCallNotifications(unreadCallsCount);
			    setUnreadMessageNotifications(unreadMessagesCount);
		    });
	    });
	mAccountModelConnection->makeConnectToModel(&AccountModel::displayNameChanged, [this](QString displayName) {
		mAccountModelConnection->invokeToCore([this, displayName]() { onDisplayNameChanged(displayName); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::dialPlanChanged, [this](int index) {
		auto dialPlan = mDialPlans[index + 1];
		mAccountModelConnection->invokeToCore([this, dialPlan]() { onDialPlanChanged(dialPlan); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::registerEnabledChanged, [this](bool enabled) {
		mAccountModelConnection->invokeToCore([this, enabled]() { onRegisterEnabledChanged(enabled); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::notificationsAllowedChanged, [this](bool value) {
		mAccountModelConnection->invokeToCore([this, value]() { onNotificationsAllowedChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::mwiServerAddressChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onMwiServerAddressChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::transportChanged, [this](linphone::TransportType value) {
		mAccountModelConnection->invokeToCore(
		    [this, value]() { onTransportChanged(LinphoneEnums::toString(LinphoneEnums::fromLinphone(value))); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::serverAddressChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onServerAddressChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::outboundProxyEnabledChanged, [this](bool value) {
		mAccountModelConnection->invokeToCore([this, value]() { onOutboundProxyEnabledChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::stunServerChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onStunServerChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::iceEnabledChanged, [this](bool value) {
		mAccountModelConnection->invokeToCore([this, value]() { onIceEnabledChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::avpfEnabledChanged, [this](bool value) {
		mAccountModelConnection->invokeToCore([this, value]() { onAvpfEnabledChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::bundleModeEnabledChanged, [this](bool value) {
		mAccountModelConnection->invokeToCore([this, value]() { onBundleModeEnabledChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::expireChanged, [this](int value) {
		mAccountModelConnection->invokeToCore([this, value]() { onExpireChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::conferenceFactoryAddressChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onConferenceFactoryAddressChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::audioVideoConferenceFactoryAddressChanged,
	                                            [this](QString value) {
		                                            mAccountModelConnection->invokeToCore([this, value]() {
			                                            onAudioVideoConferenceFactoryAddressChanged(value);
		                                            });
	                                            });
	mAccountModelConnection->makeConnectToModel(&AccountModel::limeServerUrlChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onLimeServerUrlChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::removed, [this]() { mAccountModelConnection->invokeToCore([this]() { emit removed(); }); });

	// From GUI
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetPictureUri, [this](QString uri) {
		mAccountModelConnection->invokeToModel([this, uri]() { mAccountModel->setPictureUri(uri); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetDefaultAccount, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mAccountModel->setDefault(); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lResetMissedCalls, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mAccountModel->resetMissedCallsCount(); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lRefreshNotifications, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mAccountModel->refreshUnreadNotifications(); });
	});
	mCoreModelConnection = QSharedPointer<SafeConnection<AccountCore, CoreModel>>(
	    new SafeConnection<AccountCore, CoreModel>(me, CoreModel::getInstance()));
	mAccountModelConnection->makeConnectToCore(&AccountCore::unreadCallNotificationsChanged, [this]() {
		mAccountModelConnection->invokeToModel([this]() { CoreModel::getInstance()->unreadNotificationsChanged(); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::unreadMessageNotificationsChanged, [this]() {
		mAccountModelConnection->invokeToModel([this]() { CoreModel::getInstance()->unreadNotificationsChanged(); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::unreadNotificationsChanged, [this]() {
		mAccountModelConnection->invokeToModel([this]() { CoreModel::getInstance()->unreadNotificationsChanged(); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetDisplayName, [this](QString displayName) {
		mAccountModelConnection->invokeToModel([this, displayName]() { mAccountModel->setDisplayName(displayName); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetDialPlan, [this](QString dialPlan) {
		auto dialPlanIndex = getDialPlanIndex(dialPlan);
		mAccountModelConnection->invokeToModel(
		    [this, dialPlanIndex]() { mAccountModel->setDialPlan(dialPlanIndex - 1); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetRegisterEnabled, [this](bool enabled) {
		mAccountModelConnection->invokeToModel([this, enabled]() { mAccountModel->setRegisterEnabled(enabled); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetNotificationsAllowed, [this](bool value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setNotificationsAllowed(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetMwiServerAddress, [this](QString value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setMwiServerAddress(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetTransport, [this](QString value) {
		LinphoneEnums::TransportType transport;
		LinphoneEnums::fromString(value, &transport);
		mAccountModelConnection->invokeToModel(
		    [this, value, transport]() { mAccountModel->setTransport(LinphoneEnums::toLinphone(transport)); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetServerAddress, [this](QString value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setServerAddress(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetOutboundProxyEnabled, [this](bool value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setOutboundProxyEnabled(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetStunServer, [this](QString value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setStunServer(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetIceEnabled, [this](bool value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setIceEnabled(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetAvpfEnabled, [this](bool value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setAvpfEnabled(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetBundleModeEnabled, [this](bool value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setBundleModeEnabled(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetExpire, [this](int value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setExpire(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetConferenceFactoryAddress, [this](QString value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setConferenceFactoryAddress(value); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetAudioVideoConferenceFactoryAddress,
	                                           [this](QString value) {
		                                           mAccountModelConnection->invokeToModel([this, value]() {
			                                           mAccountModel->setAudioVideoConferenceFactoryAddress(value);
		                                           });
	                                           });
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetLimeServerUrl, [this](QString value) {
		mAccountModelConnection->invokeToModel([this, value]() { mAccountModel->setLimeServerUrl(value); });
	});

	DEFINE_CORE_GET_CONNECT(mAccountModelConnection, AccountCore, AccountModel, mAccountModel, int, voicemailCount,
	                        VoicemailCount)
}

const std::shared_ptr<AccountModel> &AccountCore::getModel() const {
	return mAccountModel;
}

QString AccountCore::getContactAddress() const {
	return mContactAddress;
}

QString AccountCore::getIdentityAddress() const {
	return mIdentityAddress;
}

QString AccountCore::getPictureUri() const {
	return mPictureUri;
}

LinphoneEnums::RegistrationState AccountCore::getRegistrationState() const {
	return mRegistrationState;
}

bool AccountCore::getIsDefaultAccount() const {
	return mIsDefaultAccount;
}

int AccountCore::getUnreadNotifications() const {
	return mUnreadNotifications;
}
void AccountCore::setUnreadNotifications(int unread) {
	if (mUnreadNotifications != unread) {
		mUnreadNotifications = unread;
		emit unreadNotificationsChanged(unread);
	}
}

int AccountCore::getUnreadCallNotifications() const {
	return mUnreadCallNotifications;
}
void AccountCore::setUnreadCallNotifications(int unread) {
	if (mUnreadCallNotifications != unread) {
		mUnreadCallNotifications = unread;
		emit unreadCallNotificationsChanged(unread);
	}
}

int AccountCore::getUnreadMessageNotifications() const {
	return mUnreadMessageNotifications;
}
void AccountCore::setUnreadMessageNotifications(int unread) {
	if (mUnreadMessageNotifications != unread) {
		mUnreadMessageNotifications = unread;
		emit unreadMessageNotificationsChanged(unread);
	}
}

void AccountCore::onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
                                             linphone::RegistrationState state,
                                             const std::string &message) {
	lDebug() << log().arg(Q_FUNC_INFO) << (int)state;
	mRegistrationState = LinphoneEnums::fromLinphone(state);
	emit registrationStateChanged(Utils::coreStringToAppString(message));
}

void AccountCore::onDefaultAccountChanged(bool isDefault) {
	if (mIsDefaultAccount != isDefault) {
		mIsDefaultAccount = isDefault;
		emit defaultAccountChanged(mIsDefaultAccount);
	}
}

void AccountCore::onPictureUriChanged(QString uri) {
	if (uri != mPictureUri) {
		mPictureUri = uri;
		emit pictureUriChanged();
	}
}

void AccountCore::removeAccount() {
	mAccountModelConnection->invokeToModel([this]() { mAccountModel->removeAccount(); });
}

QString AccountCore::getDisplayName() const {
	return mDisplayName;
}

void AccountCore::onDisplayNameChanged(QString displayName) {
	if (displayName != mDisplayName) {
		mDisplayName = displayName;
		emit displayNameChanged();
	}
}

QStringList AccountCore::getDialPlans() {
	return mDialPlans;
}

QString AccountCore::getDialPlan() const {
	return mDialPlan;
}

void AccountCore::onDialPlanChanged(QString dialPlan) {
	if (dialPlan != mDialPlan) {
		mDialPlan = dialPlan;
		emit dialPlanChanged();
	}
}

int AccountCore::getDialPlanIndex(QString dialPlanString) {
	return mDialPlans.indexOf(dialPlanString);
}

QString AccountCore::getHumanReadableRegistrationState() const {
	switch (mRegistrationState) {
		case LinphoneEnums::RegistrationState::Ok:
			return tr("Connecté");
		case LinphoneEnums::RegistrationState::Refreshing:
			return tr("En cours de rafraîchissement…");
		case LinphoneEnums::RegistrationState::Progress:
			return tr("En cours de connexion…");
		case LinphoneEnums::RegistrationState::Failed:
			return tr("Erreur");
		case LinphoneEnums::RegistrationState::None:
		case LinphoneEnums::RegistrationState::Cleared:
			return tr("Désactivé");
		default:
			return " ";
	}
}

QString AccountCore::getHumanReadableRegistrationStateExplained() const {
	switch (mRegistrationState) {
		case LinphoneEnums::RegistrationState::Ok:
			return tr("Vous êtes en ligne et joignable.");
		case LinphoneEnums::RegistrationState::Failed:
			return tr("Erreur de connexion, vérifiez vos paramètres.");
		case LinphoneEnums::RegistrationState::None:
		case LinphoneEnums::RegistrationState::Cleared:
			return tr("Compte désactivé, vous ne recevrez ni appel ni message.");
		default:
			return " ";
	}
}

bool AccountCore::getRegisterEnabled() const {
	return mRegisterEnabled;
}

void AccountCore::onRegisterEnabledChanged(bool enabled) {
	if (enabled != mRegisterEnabled) {
		mRegisterEnabled = enabled;
		emit registerEnabledChanged();
	}
}

bool AccountCore::getNotificationsAllowed() {
	return mNotificationsAllowed;
}

QString AccountCore::getMwiServerAddress() {
	return mMwiServerAddress;
}

QStringList AccountCore::getTransports() {
	return mTransports;
}

QString AccountCore::getTransport() {
	return mTransport;
}

QString AccountCore::getServerAddress() {
	return mServerAddress;
}

bool AccountCore::getOutboundProxyEnabled() {
	return mOutboundProxyEnabled;
}

QString AccountCore::getStunServer() {
	return mStunServer;
}

bool AccountCore::getIceEnabled() {
	return mIceEnabled;
}

bool AccountCore::getAvpfEnabled() {
	return mAvpfEnabled;
}

bool AccountCore::getBundleModeEnabled() {
	return mBundleModeEnabled;
}

int AccountCore::getExpire() {
	return mExpire;
}

QString AccountCore::getConferenceFactoryAddress() {
	return mConferenceFactoryAddress;
}

QString AccountCore::getAudioVideoConferenceFactoryAddress() {
	return mAudioVideoConferenceFactoryAddress;
}

QString AccountCore::getLimeServerUrl() {
	return mLimeServerUrl;
}

void AccountCore::onNotificationsAllowedChanged(bool value) {
	if (value != mNotificationsAllowed) {
		mNotificationsAllowed = value;
		emit notificationsAllowedChanged();
	}
}

void AccountCore::onMwiServerAddressChanged(QString value) {
	if (value != mMwiServerAddress) {
		mMwiServerAddress = value;
		emit mwiServerAddressChanged();
	}
}

void AccountCore::onTransportChanged(QString value) {
	if (value != mTransport) {
		mTransport = value;
		emit transportChanged();
	}
}

void AccountCore::onServerAddressChanged(QString value) {
	if (value != mServerAddress) {
		mServerAddress = value;
		emit serverAddressChanged();
	}
}

void AccountCore::onOutboundProxyEnabledChanged(bool value) {
	if (value != mOutboundProxyEnabled) {
		mOutboundProxyEnabled = value;
		emit outboundProxyEnabledChanged();
	}
}
void AccountCore::onStunServerChanged(QString value) {
	if (value != mStunServer) {
		mStunServer = value;
		emit stunServerChanged();
	}
}

void AccountCore::onIceEnabledChanged(bool value) {
	if (value != mIceEnabled) {
		mIceEnabled = value;
		emit iceEnabledChanged();
	}
}

void AccountCore::onAvpfEnabledChanged(bool value) {
	if (value != mAvpfEnabled) {
		mAvpfEnabled = value;
		emit avpfEnabledChanged();
	}
}

void AccountCore::onBundleModeEnabledChanged(bool value) {
	if (value != mBundleModeEnabled) {
		mBundleModeEnabled = value;
		emit bundleModeEnabledChanged();
	}
}

void AccountCore::onExpireChanged(int value) {
	if (value != mExpire) {
		mExpire = value;
		emit expireChanged();
	}
}

void AccountCore::onConferenceFactoryAddressChanged(QString value) {
	if (value != mConferenceFactoryAddress) {
		mConferenceFactoryAddress = value;
		emit conferenceFactoryAddressChanged();
	}
}

void AccountCore::onAudioVideoConferenceFactoryAddressChanged(QString value) {
	if (value != mAudioVideoConferenceFactoryAddress) {
		mAudioVideoConferenceFactoryAddress = value;
		emit audioVideoConferenceFactoryAddressChanged();
	}
}

void AccountCore::onLimeServerUrlChanged(QString value) {
	if (value != mLimeServerUrl) {
		mLimeServerUrl = value;
		emit limeServerUrlChanged();
	}
}
