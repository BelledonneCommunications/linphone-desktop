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
	auto params = account->getParams()->clone();
	auto identityAddress = params->getIdentityAddress();
	mIdentityAddress = identityAddress ? Utils::coreStringToAppString(identityAddress->asStringUriOnly()) : "";
	mPictureUri = Utils::coreStringToAppString(params->getPictureUri());
	mRegistrationState = LinphoneEnums::fromLinphone(account->getState());
	mIsDefaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount() == account;
	mUnreadNotifications = account->getMissedCallsCount() + account->getUnreadChatMessageCount();
	mDisplayName = Utils::coreStringToAppString(identityAddress->getDisplayName());
	mPublishEnabled = params->publishEnabled();
	if (mDisplayName.isEmpty()) {
		mDisplayName = ToolModel::getDisplayName(identityAddress);
		auto copyAddress = identityAddress->clone();
		copyAddress->setDisplayName(Utils::appStringToCoreString(mDisplayName));
		params->setIdentityAddress(copyAddress);
		account->setParams(params);
	}
	mRegisterEnabled = params->registerEnabled();
	mMwiServerAddress =
	    params->getMwiServerAddress() ? Utils::coreStringToAppString(params->getMwiServerAddress()->asString()) : "";
	mTransports << "UDP"
	            << "TCP"
	            << "TLS"
	            << "DTLS";
	mTransport = LinphoneEnums::toString(LinphoneEnums::fromLinphone(params->getTransport()));
	mRegistrarUri =
	    params->getServerAddress() ? Utils::coreStringToAppString(params->getServerAddress()->asString()) : "";
	auto routesAddresses = params->getRoutesAddresses();
	mOutboundProxyUri =
	    routesAddresses.empty() ? "" : Utils::coreStringToAppString(routesAddresses.front()->asString());
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
	mExplicitPresence = LinphoneEnums::fromString(
	    Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getConfig()->getString(
	        ToolModel::configAccountSection(account), "explicit_presence", "")));
	mPresenceNote = Utils::coreStringToAppString(CoreModel::getInstance()->getCore()->getConfig()->getString(
	    ToolModel::configAccountSection(account), "presence_note", ""));
	mMaxPresenceNoteSize = CoreModel::getInstance()->getCore()->getConfig()->getInt(
	    ToolModel::configAccountSection(account), "max_presence_note_size", 140);
	mPresence = mAccountModel->getPresence();
	mNotificationsAllowed = mAccountModel->getNotificationsAllowed();
	mDialPlan = Utils::createDialPlanVariant("", " ");
	mDialPlans << mDialPlan;
	for (auto dialPlan : linphone::Factory::get()->getDialPlans()) {
		mDialPlans << Utils::createDialPlanVariant(
		    Utils::coreStringToAppString(dialPlan->getFlag()),
		    Utils::coreStringToAppString(dialPlan->getCountry() + " | +" + dialPlan->getCountryCallingCode()));
		if (dialPlan->getCountryCallingCode() == account->getParams()->getInternationalPrefix()) {
			mDialPlan = mDialPlans.last().toMap();
		}
	}
	mVoicemailAddress =
	    params->getVoicemailAddress() ? Utils::coreStringToAppString(params->getVoicemailAddress()->asString()) : "";

	INIT_CORE_MEMBER(VoicemailCount, mAccountModel)
	INIT_CORE_MEMBER(ShowMwi, mAccountModel)
}

AccountCore::~AccountCore() {
	mustBeInMainThread("~" + getClassName());
	if (mAccountModel) emit mAccountModel->removeListener();
}

AccountCore::AccountCore(const AccountCore &accountCore) {
	mContactAddress = accountCore.mContactAddress;
	mIdentityAddress = accountCore.mIdentityAddress;
	mPictureUri = accountCore.mPictureUri;
	mDisplayName = accountCore.mDisplayName;
	mDialPlans = accountCore.mDialPlans;
	mDialPlan = accountCore.mDialPlan;
	mRegisterEnabled = accountCore.mRegisterEnabled;
	mIsDefaultAccount = accountCore.mIsDefaultAccount;
	mRegistrationState = accountCore.mRegistrationState;
	mUnreadNotifications = accountCore.mUnreadNotifications;
	mUnreadCallNotifications = accountCore.mUnreadCallNotifications;
	mUnreadMessageNotifications = accountCore.mUnreadMessageNotifications;
	mDevices = accountCore.mDevices;
	mNotificationsAllowed = accountCore.mNotificationsAllowed;
	mMwiServerAddress = accountCore.mMwiServerAddress;
	mVoicemailAddress = accountCore.mVoicemailAddress;
	mTransport = accountCore.mTransport;
	mTransports = accountCore.mTransports;
	mRegistrarUri = accountCore.mRegistrarUri;
	mOutboundProxyUri = accountCore.mOutboundProxyUri;
	mStunServer = accountCore.mStunServer;
	mIceEnabled = accountCore.mIceEnabled;
	mAvpfEnabled = accountCore.mAvpfEnabled;
	mBundleModeEnabled = accountCore.mBundleModeEnabled;
	mExpire = accountCore.mExpire;
	mConferenceFactoryAddress = accountCore.mConferenceFactoryAddress;
	mAudioVideoConferenceFactoryAddress = accountCore.mAudioVideoConferenceFactoryAddress;
	mLimeServerUrl = accountCore.mLimeServerUrl;
}

void AccountCore::setSelf(QSharedPointer<AccountCore> me) {
	mAccountModelConnection = SafeConnection<AccountCore, AccountModel>::create(me, mAccountModel);
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::registrationStateChanged, [this](const std::shared_ptr<linphone::Account> &account,
	                                                    linphone::RegistrationState state, const std::string &message) {
		    mAccountModelConnection->invokeToCore(
		        [this, account, state, message]() { onRegistrationStateChanged(account, state, message); });
	    });
	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::conferenceInformationUpdated,
	    [this](const std::shared_ptr<linphone::Account> &account,
	           const std::list<std::shared_ptr<linphone::ConferenceInfo>> &infos) {
		    mAccountModelConnection->invokeToCore([this]() { emit conferenceInformationUpdated(); });
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
		auto dialPlan = mDialPlans[index + 1].toMap();
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
	mAccountModelConnection->makeConnectToModel(&AccountModel::voicemailAddressChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onVoicemailAddressChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::transportChanged, [this](linphone::TransportType value) {
		mAccountModelConnection->invokeToCore(
		    [this, value]() { onTransportChanged(LinphoneEnums::toString(LinphoneEnums::fromLinphone(value))); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::registrarUriChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onRegistrarUriChanged(value); });
	});
	mAccountModelConnection->makeConnectToModel(&AccountModel::outboundProxyUriChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { onOutboundProxyUriChanged(value); });
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

	mAccountModelConnection->makeConnectToModel(
	    &AccountModel::presenceChanged, [this](LinphoneEnums::Presence presence, bool userInitiated) {
		    mAccountModelConnection->invokeToCore([this, presence, userInitiated]() {
			    if (userInitiated) mExplicitPresence = presence;
			    else mExplicitPresence = LinphoneEnums::Presence::Undefined;
			    mPresence = presence;
			    emit presenceChanged();
		    });
	    });

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
	mAccountModelConnection->makeConnectToCore(&AccountCore::lResetUnreadMessages, [this]() {
		mAccountModelConnection->invokeToModel([this]() {
			auto chatRooms = mAccountModel->getChatRooms();
			for (auto const &chatRoom : chatRooms) {
				chatRoom->markAsRead();
			}
		});
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lRefreshNotifications, [this]() {
		mAccountModelConnection->invokeToModel([this]() { mAccountModel->refreshUnreadNotifications(); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetDisplayName, [this](QString displayName) {
		mAccountModelConnection->invokeToModel([this, displayName]() { mAccountModel->setDisplayName(displayName); });
	});
	mAccountModelConnection->makeConnectToCore(&AccountCore::lSetDialPlan, [this](QVariantMap dialPlan) {
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
	mAccountModelConnection->makeConnectToCore(
	    &AccountCore::lSetPresence, [this](LinphoneEnums::Presence presence, bool userInitiated, bool resetToAuto) {
		    mAccountModelConnection->invokeToModel(
		        [this, presence, userInitiated, resetToAuto, presenceNote = mPresenceNote]() {
			        mAccountModel->setPresence(presence, userInitiated, resetToAuto, presenceNote);
		        });
	    });

	DEFINE_CORE_GET_CONNECT(mAccountModelConnection, AccountCore, AccountModel, mAccountModel, int, voicemailCount,
	                        VoicemailCount)
	DEFINE_CORE_GET_CONNECT(mAccountModelConnection, AccountCore, AccountModel, mAccountModel, int, showMwi, ShowMwi)
	// DEFINE_CORE_GETSET_CONNECT(mAccountModelConnection, AccountCore, AccountModel, mAccountModel, QString,
	//    voicemailAddress, VoicemailAddress)
	mAccountModelConnection->makeConnectToModel(&AccountModel::voicemailAddressChanged, [this](QString value) {
		mAccountModelConnection->invokeToCore([this, value]() { setVoicemailAddress(value); });
	});

	mCoreModelConnection = SafeConnection<AccountCore, CoreModel>::create(me, CoreModel::getInstance());
	mCoreModelConnection->makeConnectToModel(&CoreModel::messageReadInChatRoom,
	                                         [this] { mAccountModel->refreshUnreadNotifications(); });

	mAccountModelConnection->makeConnectToModel(&AccountModel::setValueFailed, [this](const QString &errorMessage) {
		mAccountModelConnection->invokeToCore([this, errorMessage]() { emit setValueFailed(errorMessage); });
	});
}

void AccountCore::reset(const AccountCore &accountCore) {
	setUnreadNotifications(accountCore.mUnreadNotifications);
	setUnreadCallNotifications(accountCore.mUnreadCallNotifications);
	setUnreadMessageNotifications(accountCore.mUnreadMessageNotifications);
	onMwiServerAddressChanged(accountCore.mMwiServerAddress);
	onVoicemailAddressChanged(accountCore.mVoicemailAddress);
	onTransportChanged(accountCore.mTransport);
	onRegistrarUriChanged(accountCore.mRegistrarUri);
	onOutboundProxyUriChanged(accountCore.mOutboundProxyUri);
	setStunServer(accountCore.mStunServer);
	onIceEnabledChanged(accountCore.mIceEnabled);
	onAvpfEnabledChanged(accountCore.mAvpfEnabled);
	onBundleModeEnabledChanged(accountCore.mBundleModeEnabled);
	onExpireChanged(accountCore.mExpire);
	onConferenceFactoryAddressChanged(accountCore.mConferenceFactoryAddress);
	onAudioVideoConferenceFactoryAddressChanged(accountCore.mAudioVideoConferenceFactoryAddress);
	onLimeServerUrlChanged(accountCore.mLimeServerUrl);
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
	mRegistrationState = LinphoneEnums::fromLinphone(state);
	qDebug() << log().arg(Q_FUNC_INFO) << mRegistrationState;
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

QVariantList AccountCore::getDialPlans() {
	return mDialPlans;
}

QVariantMap AccountCore::getDialPlan() const {
	return mDialPlan;
}

void AccountCore::onDialPlanChanged(QVariantMap dialPlan) {
	if (dialPlan != mDialPlan) {
		mDialPlan = dialPlan;
		emit dialPlanChanged();
	}
}

int AccountCore::getDialPlanIndex(QVariantMap dialPlanString) {
	return mDialPlans.indexOf(dialPlanString);
}

QString AccountCore::getHumanReadableRegistrationState() const {
	switch (mRegistrationState) {
		case LinphoneEnums::RegistrationState::Ok:
			//: "Connecté"
			return tr("drawer_menu_account_connection_status_connected");
		case LinphoneEnums::RegistrationState::Refreshing:
			// "En cours de rafraîchissement…"
			return tr("drawer_menu_account_connection_status_refreshing");
		case LinphoneEnums::RegistrationState::Progress:
			// "Connexion…"
			return tr("drawer_menu_account_connection_status_progress");
		case LinphoneEnums::RegistrationState::Failed:
			// "Erreur"
			return tr("drawer_menu_account_connection_status_failed");
		case LinphoneEnums::RegistrationState::None:
		case LinphoneEnums::RegistrationState::Cleared:
			// "Désactivé"
			return tr("drawer_menu_account_connection_status_cleared");
		default:
			return " ";
	}
}

QColor AccountCore::getRegistrationColor() const {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	switch (mRegistrationState) {
		case LinphoneEnums::RegistrationState::Ok:
			return Utils::getDefaultStyleColor("success_500_main");
		case LinphoneEnums::RegistrationState::Refreshing:
			return Utils::getDefaultStyleColor("main2_500_main");
		case LinphoneEnums::RegistrationState::Progress:
			return Utils::getDefaultStyleColor("main2_500_main");
		case LinphoneEnums::RegistrationState::Failed:
			return Utils::getDefaultStyleColor("danger_500_main");
		case LinphoneEnums::RegistrationState::None:
		case LinphoneEnums::RegistrationState::Cleared:
			return Utils::getDefaultStyleColor("warning_600");
		default:
			return " ";
	}
}

QUrl AccountCore::getRegistrationIcon() const {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	return Utils::getRegistrationStateIcon(mRegistrationState);
}

QString AccountCore::getHumanReadableRegistrationStateExplained() const {
	switch (mRegistrationState) {
		case LinphoneEnums::RegistrationState::Ok:
			//: "Vous êtes en ligne et joignable."
			return tr("manage_account_status_connected_summary");
		case LinphoneEnums::RegistrationState::Failed:
			//: "Erreur de connexion, vérifiez vos paramètres."
			return tr("manage_account_status_failed_summary");
		case LinphoneEnums::RegistrationState::None:
		case LinphoneEnums::RegistrationState::Cleared:
			//: "Compte désactivé, vous ne recevrez ni appel ni message."
			return tr("manage_account_status_cleared_summary");
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

QString AccountCore::getVoicemailAddress() {
	return mVoicemailAddress;
}

QStringList AccountCore::getTransports() {
	return mTransports;
}

QString AccountCore::getTransport() {
	return mTransport;
}

QString AccountCore::getRegistrarUri() {
	return mRegistrarUri;
}

QString AccountCore::getOutboundProxyUri() {
	return mOutboundProxyUri;
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

void AccountCore::setMwiServerAddress(QString value) {
	if (mMwiServerAddress != value) {
		mMwiServerAddress = value;
		emit mwiServerAddressChanged();
		setIsSaved(false);
	}
}

void AccountCore::setVoicemailAddress(QString value) {
	if (mVoicemailAddress != value) {
		mVoicemailAddress = value;
		emit voicemailAddressChanged();
		setIsSaved(false);
	}
}

void AccountCore::setTransport(QString value) {
	if (mTransport != value) {
		mTransport = value;
		emit transportChanged();
		setIsSaved(false);
	}
}

void AccountCore::setRegistrarUri(QString value) {
	if (mRegistrarUri != value) {
		mRegistrarUri = value;
		emit registrarUriChanged();
		setIsSaved(false);
	}
}

void AccountCore::setOutboundProxyUri(QString value) {
	if (mOutboundProxyUri != value) {
		mOutboundProxyUri = value;
		emit outboundProxyUriChanged();
		setIsSaved(false);
	}
}

void AccountCore::setStunServer(QString value) {
	if (mStunServer != value) {
		mStunServer = value;
		emit stunServerChanged();
		setIsSaved(false);
	}
}

void AccountCore::setIceEnabled(bool value) {
	if (mIceEnabled != value) {
		mIceEnabled = value;
		emit iceEnabledChanged();
		setIsSaved(false);
	}
}

void AccountCore::setAvpfEnabled(bool value) {
	if (mAvpfEnabled != value) {
		mAvpfEnabled = value;
		emit avpfEnabledChanged();
		setIsSaved(false);
	}
}

void AccountCore::setBundleModeEnabled(bool value) {
	if (mBundleModeEnabled != value) {
		mBundleModeEnabled = value;
		emit bundleModeEnabledChanged();
		setIsSaved(false);
	}
}

void AccountCore::setExpire(int value) {
	if (mExpire != value) {
		mExpire = value;
		emit expireChanged();
		setIsSaved(false);
	}
}

void AccountCore::setConferenceFactoryAddress(QString value) {
	if (mConferenceFactoryAddress != value) {
		mConferenceFactoryAddress = value;
		emit conferenceFactoryAddressChanged();
		setIsSaved(false);
	}
}

void AccountCore::setAudioVideoConferenceFactoryAddress(QString value) {
	if (mAudioVideoConferenceFactoryAddress != value) {
		mAudioVideoConferenceFactoryAddress = value;
		emit audioVideoConferenceFactoryAddressChanged();
		setIsSaved(false);
	}
}

void AccountCore::setLimeServerUrl(QString value) {
	if (mLimeServerUrl != value) {
		mLimeServerUrl = value;
		emit limeServerUrlChanged();
		setIsSaved(false);
	}
}

bool AccountCore::isSaved() const {
	return mIsSaved;
}

void AccountCore::setIsSaved(bool saved) {
	if (mIsSaved != saved) {
		mIsSaved = saved;
		emit isSavedChanged();
	}
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

void AccountCore::onVoicemailAddressChanged(QString value) {
	if (value != mVoicemailAddress) {
		mVoicemailAddress = value;
		emit voicemailAddressChanged();
	}
}

void AccountCore::onTransportChanged(QString value) {
	if (value != mTransport) {
		mTransport = value;
		emit transportChanged();
	}
}

void AccountCore::onRegistrarUriChanged(QString value) {
	if (value != mRegistrarUri) {
		mRegistrarUri = value;
		emit registrarUriChanged();
	}
}

void AccountCore::onOutboundProxyUriChanged(QString value) {
	if (value != mOutboundProxyUri) {
		mOutboundProxyUri = value;
		emit outboundProxyUriChanged();
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
	if (mIsDefaultAccount) {
		SettingsModel::getInstance()->setDisableMeetingsFeature(value.isEmpty());
	}
}

void AccountCore::onLimeServerUrlChanged(QString value) {
	if (value != mLimeServerUrl) {
		mLimeServerUrl = value;
		emit limeServerUrlChanged();
	}
}

void AccountCore::writeIntoModel(std::shared_ptr<AccountModel> model) const {
	mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
	model->setMwiServerAddress(mMwiServerAddress);
	LinphoneEnums::TransportType transport;
	LinphoneEnums::fromString(mTransport, &transport);
	model->setTransport(LinphoneEnums::toLinphone(transport), true);
	model->setRegistrarUri(mRegistrarUri);
	model->setOutboundProxyUri(mOutboundProxyUri);
	model->setStunServer(mStunServer);
	model->setIceEnabled(mIceEnabled);
	model->setAvpfEnabled(mAvpfEnabled);
	model->setBundleModeEnabled(mBundleModeEnabled);
	model->setExpire(mExpire);
	model->setConferenceFactoryAddress(mConferenceFactoryAddress);
	model->setAudioVideoConferenceFactoryAddress(mAudioVideoConferenceFactoryAddress);
	model->setLimeServerUrl(mLimeServerUrl);
	model->setVoicemailAddress(mVoicemailAddress);
}

void AccountCore::writeFromModel(const std::shared_ptr<AccountModel> &model) {
	mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
	setUnreadCallNotifications(model->getMissedCallsCount());
	setUnreadMessageNotifications(model->getUnreadMessagesCount());
	onMwiServerAddressChanged(model->getMwiServerAddress());
	onTransportChanged(LinphoneEnums::toString(LinphoneEnums::fromLinphone(model->getTransport())));
	onRegistrarUriChanged(model->getRegistrarUri());
	onOutboundProxyUriChanged(model->getOutboundProxyUri());
	onStunServerChanged(model->getStunServer());
	onIceEnabledChanged(model->getIceEnabled());
	onAvpfEnabledChanged(model->getAvpfEnabled());
	onBundleModeEnabledChanged(model->getBundleModeEnabled());
	onExpireChanged(model->getExpire());
	onConferenceFactoryAddressChanged(model->getConferenceFactoryAddress());
	onAudioVideoConferenceFactoryAddressChanged(model->getAudioVideoConferenceFactoryAddress());
	onLimeServerUrlChanged(model->getLimeServerUrl());
	onVoicemailAddressChanged(model->getVoicemailAddress());
}

void AccountCore::save() {
	mustBeInMainThread(getClassName() + Q_FUNC_INFO);
	if (mAccountModel) {
		AccountCore *thisCopy = new AccountCore(*this);
		mAccountModelConnection->invokeToModel([this, thisCopy] {
			mustBeInLinphoneThread(getClassName() + Q_FUNC_INFO);
			thisCopy->writeIntoModel(mAccountModel);
			thisCopy->deleteLater();
			mAccountModelConnection->invokeToCore([this, thisCopy]() {
				setIsSaved(true);
				undo(); // Reset new values because some values can be invalid and not changed.
			});
		});
	}
}

void AccountCore::undo() {
	if (mAccountModel) {
		mAccountModelConnection->invokeToModel([this] {
			AccountCore *account = new AccountCore(*this);
			account->writeFromModel(mAccountModel);
			account->moveToThread(App::getInstance()->thread());
			mAccountModelConnection->invokeToCore([this, account]() {
				this->reset(*account);
				account->deleteLater();
			});
		});
	}
}

LinphoneEnums::Presence AccountCore::getPresence() {
	return mPresence;
}

QColor AccountCore::getPresenceColor() {
	return Utils::getPresenceColor(mPresence);
}

QUrl AccountCore::getPresenceIcon() {
	return Utils::getPresenceIcon(mPresence);
}

QString AccountCore::getPresenceStatus() {
	return Utils::getPresenceStatus(mPresence);
}

void AccountCore::resetToAutomaticPresence() {
	emit lSetPresence(LinphoneEnums::Presence::Online, false, true);
}

LinphoneEnums::Presence AccountCore::getExplicitPresence() {
	return mExplicitPresence;
}

void AccountCore::setPresenceNote(QString presenceNote) {
	if (presenceNote != mPresenceNote) {
		mPresenceNote = presenceNote;
		emit lSetPresence(mPresence, mExplicitPresence != LinphoneEnums::Presence::Undefined, false);
	}
}

QString AccountCore::getPresenceNote() {
	return mPresenceNote;
}
