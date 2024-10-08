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

#include "ToolModel.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
#include <QDebug>
#include <QTest>

DEFINE_ABSTRACT_OBJECT(ToolModel)

ToolModel::ToolModel(QObject *parent) {
}
ToolModel::~ToolModel() {
}
std::shared_ptr<linphone::Address> ToolModel::interpretUrl(const QString &address) {
	bool usePrefix = false; // TODO
	// CoreManager::getInstance()->getAccountSettingsModel()->getUseInternationalPrefixForCallsAndChats();
	auto interpretedAddress =
	    CoreModel::getInstance()->getCore()->interpretUrl(Utils::appStringToCoreString(address), usePrefix);
	if (!interpretedAddress) { // Try by removing scheme.
		QStringList splitted = address.split(":");
		if (splitted.size() > 0 && splitted[0] == "sip") {
			splitted.removeFirst();
			interpretedAddress = CoreModel::getInstance()->getCore()->interpretUrl(
			    Utils::appStringToCoreString(splitted.join(":")), usePrefix);
		}
	}
	return interpretedAddress;
}

std::shared_ptr<linphone::FriendPhoneNumber> ToolModel::makeLinphoneNumber(const QString &label,
                                                                           const QString &number) {
	auto linphoneNumber = std::make_shared<linphone::FriendPhoneNumber>(nullptr);
	linphoneNumber->setLabel(Utils::appStringToCoreString(label));
	linphoneNumber->setLabel(Utils::appStringToCoreString(number));
	return linphoneNumber;
}

std::shared_ptr<linphone::AudioDevice> ToolModel::findAudioDevice(const QString &id) {
	std::string devId = Utils::appStringToCoreString(id);
	auto devices = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice =
	    find_if(devices.cbegin(), devices.cend(),
	            [&](const std::shared_ptr<linphone::AudioDevice> &audioItem) { return audioItem->getId() == devId; });
	if (audioDevice != devices.cend()) {
		return *audioDevice;
	}
	return nullptr;
}

QString ToolModel::getDisplayName(const std::shared_ptr<const linphone::Address> &address) {
	QString displayName;
	if (address) {
		displayName = Utils::coreStringToAppString(address->getDisplayName());
		if (displayName.isEmpty()) {
			displayName = Utils::coreStringToAppString(address->getUsername());
			displayName.replace('.', ' ');
		}
		// TODO
		//	std::shared_ptr<linphone::Address> cleanAddress = address->clone();
		//	cleanAddress->clean();
		//	QString qtAddress = Utils::coreStringToAppString(cleanAddress->asStringUriOnly());
		//	auto sipAddressEntry = getSipAddressEntry(qtAddress, cleanAddress);
		//	displayName = sipAddressEntry->displayNames.get();
	}
	return displayName;
}

QString ToolModel::getDisplayName(QString address) {
	mustBeInLinphoneThread(QString(gClassName) + " : " + Q_FUNC_INFO);

	QString displayName = getDisplayName(interpretUrl(address));
	if (displayName.isEmpty()) return address;
	QStringList nameSplitted = displayName.split(" ");
	for (auto &part : nameSplitted) {
		if (part.isEmpty()) continue;
		part[0] = part[0].toUpper();
	}
	return nameSplitted.join(" ");
}

bool ToolModel::createCall(const QString &sipAddress,
                           const QVariantMap &options,
                           const QString &prepareTransfertAddress,
                           const QHash<QString, QString> &headers,
                           linphone::MediaEncryption mediaEncryption,
                           QString *errorMessage) {
	bool waitRegistrationForCall = true; // getSettingsModel()->getWaitRegistrationForCall()

	std::shared_ptr<linphone::Core> core = CoreModel::getInstance()->getCore();

	if (waitRegistrationForCall) {
		std::shared_ptr<linphone::Account> currentAccount = core->getDefaultAccount();
		if (!currentAccount || currentAccount->getState() != linphone::RegistrationState::Ok) {
			connect(
			    CoreModel::getInstance().get(), &CoreModel::accountRegistrationStateChanged,
			    CoreModel::getInstance().get(),
			    [sipAddress, options, prepareTransfertAddress, headers, mediaEncryption]() {
				    ToolModel::createCall(sipAddress, options, prepareTransfertAddress, headers, mediaEncryption);
			    },
			    Qt::SingleShotConnection);
			return false;
		}
	}

	bool localVideoEnabled = options.contains("localVideoEnabled") ? options["localVideoEnabled"].toBool() : false;

	std::shared_ptr<linphone::Address> address = interpretUrl(sipAddress);

	if (!address) {
		lCritical() << "[" + QString(gClassName) + "] The calling address is not an interpretable SIP address: "
		            << sipAddress;
		if (errorMessage) {
			*errorMessage = tr("The calling address is not an interpretable SIP address : %1").arg(sipAddress);
		}
		return false;
	}
	bool isConference = !!core->findConferenceInformationFromUri(address);
	if (isConference) mediaEncryption = linphone::MediaEncryption::ZRTP;

	if (SettingsModel::dndEnabled(
	        core->getConfig())) { // Force tones for outgoing calls when in DND mode (ringback, dtmf, etc ... ) disabled
		                          // again when no more calls are running.
		SettingsModel::enableTones(core->getConfig(), true);
	}
	std::shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
	CallModel::activateLocalVideo(params, nullptr, localVideoEnabled);

	bool micEnabled = options.contains("microEnabled") ? options["microEnabled"].toBool() : true;
	params->enableMic(micEnabled);

	params->setMediaEncryption(mediaEncryption);
	if (Utils::coreStringToAppString(params->getRecordFile()).isEmpty()) {

		params->setRecordFile(
		    Paths::getCapturesDirPath()
		        .append(Utils::generateSavedFilename(QString::fromStdString(address->getUsername()), ""))
		        .append(".mkv")
		        .toStdString());
	}

	QHashIterator<QString, QString> iterator(headers);
	while (iterator.hasNext()) {
		iterator.next();
		params->addCustomHeader(Utils::appStringToCoreString(iterator.key()),
		                        Utils::appStringToCoreString(iterator.value()));
	}

	if (core->getDefaultAccount()) params->setAccount(core->getDefaultAccount());
	auto call = core->inviteAddressWithParams(address, params);
	return call != nullptr;

	/* TODO transfer

	std::shared_ptr<linphone::Account> currentAccount = core->getDefaultAccount();
	if (currentAccount) {
	    if (!waitRegistrationForCall || currentAccount->getState() == linphone::RegistrationState::Ok) {
	        qWarning() << "prepareTransfert not impolemented";
	        // CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
	    } else {
	        qWarning() << "Waiting registration not implemented";

	        // QObject *context = new QObject();
	        // QObject::connect(
	        //     CoreManager::getInstance()->getHandlers().get(), &CoreHandlers::registrationStateChanged, context,
	        //     [address, core, params, currentAccount, prepareTransfertAddress, context](
	        //         const std::shared_ptr<linphone::Account> &account, linphone::RegistrationState state) mutable {
	        //	    if (context && account == currentAccount && state == linphone::RegistrationState::Ok) {
	        //		    CallModel::prepareTransfert(core->inviteAddressWithParams(address, params),
	        //		                                prepareTransfertAddress);
	        //		    context->deleteLater();
	        //		    context = nullptr;
	        //	    }
	        //    });
	    }
	} else qWarning() << "prepareTransfert not impolemented";
	// CallModel::prepareTransfert(core->inviteAddressWithParams(address, params), prepareTransfertAddress);
	*/
}

std::shared_ptr<linphone::Account> ToolModel::findAccount(const std::shared_ptr<const linphone::Address> &address) {
	std::shared_ptr<linphone::Account> account;
	for (auto item : CoreModel::getInstance()->getCore()->getAccountList()) {
		if (item->getContactAddress() && item->getContactAddress()->weakEqual(address)) {
			account = item;
			break;
		}
	}
	return account;
}

bool ToolModel::isMe(const QString &address) {
	bool isMe = false;
	auto linAddr = ToolModel::interpretUrl(address);
	if (!CoreModel::getInstance()->getCore()->getDefaultAccount()) {
		for (auto &account : CoreModel::getInstance()->getCore()->getAccountList()) {
			if (account->getContactAddress()->weakEqual(linAddr)) return true;
		}
	} else {
		auto accountAddr = CoreModel::getInstance()->getCore()->getDefaultAccount()->getContactAddress();
		isMe = linAddr && accountAddr ? accountAddr->weakEqual(linAddr) : false;
	}
	return isMe;
}

bool ToolModel::isLocal(const QString &address) {
	auto linAddr = ToolModel::interpretUrl(address);
	if (!CoreModel::getInstance()->getCore()->getDefaultAccount()) {
		return false;
	} else {
		auto accountAddr = CoreModel::getInstance()->getCore()->getDefaultAccount()->getContactAddress();
		return linAddr && accountAddr ? accountAddr->weakEqual(linAddr) : false;
	}
}

bool ToolModel::isMe(const std::shared_ptr<const linphone::Address> &address) {
	auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	if (!currentAccount) { // Default account is selected : Me is all local accounts.
		return findAccount(address) != nullptr;
	} else return address ? currentAccount->getContactAddress()->weakEqual(address) : false;
}
bool ToolModel::isLocal(const std::shared_ptr<linphone::Conference> &conference,
                        const std::shared_ptr<const linphone::ParticipantDevice> &device) {
	auto deviceAddress = device->getAddress();
	auto callAddress = conference->getMe()->getAddress();
	auto gruuAddress = findAccount(callAddress)->getContactAddress();
	return deviceAddress->equal(gruuAddress);
}
