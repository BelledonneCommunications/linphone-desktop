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
#include "model/friend/FriendsManager.hpp"
#include "tool/Utils.hpp"
#include <QDebug>
#include <QDirIterator>
#include <QLibrary>
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

std::shared_ptr<linphone::Call> ToolModel::getCallByRemoteAddress(const QString &remoteAddress) {
	auto linAddress = ToolModel::interpretUrl(remoteAddress);
	if (linAddress) return CoreModel::getInstance()->getCore()->getCallByRemoteAddress2(linAddress);
	else return nullptr;
}

std::shared_ptr<linphone::FriendPhoneNumber> ToolModel::makeLinphoneNumber(const QString &label,
                                                                           const QString &number) {
	auto linphoneNumber = std::make_shared<linphone::FriendPhoneNumber>(nullptr);
	linphoneNumber->setLabel(Utils::appStringToCoreString(label));
	linphoneNumber->setLabel(Utils::appStringToCoreString(number));
	return linphoneNumber;
}

std::shared_ptr<linphone::AudioDevice> ToolModel::findAudioDevice(const QString &id,
                                                                  linphone::AudioDevice::Capabilities capability) {
	std::string devId = Utils::appStringToCoreString(id);
	auto devices = CoreModel::getInstance()->getCore()->getExtendedAudioDevices();
	auto audioDevice =
	    find_if(devices.cbegin(), devices.cend(), [&](const std::shared_ptr<linphone::AudioDevice> &audioItem) {
		    return audioItem->hasCapability(capability) && audioItem->getId() == devId;
	    });
	if (audioDevice != devices.cend()) {
		return *audioDevice;
	}
	return nullptr;
}

QString ToolModel::getDisplayName(const std::shared_ptr<linphone::Address> &address) {
	QString displayName;
	if (address) {
		auto linFriend = ToolModel::findFriendByAddress(address);
		if (linFriend) {
			if (displayName.isEmpty()) displayName = Utils::coreStringToAppString(linFriend->getName());
		}
		if (displayName.isEmpty()) {
			displayName = Utils::coreStringToAppString(address->getDisplayName());
			if (displayName.isEmpty()) {
				displayName = Utils::coreStringToAppString(address->getUsername());
				displayName.replace('.', ' ');
			}
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

std::shared_ptr<linphone::Friend> ToolModel::findFriendByAddress(const QString &address) {
	auto defaultFriendList = CoreModel::getInstance()->getCore()->getDefaultFriendList();
	if (!defaultFriendList) return nullptr;
	auto linphoneAddr = ToolModel::interpretUrl(address);
	if (linphoneAddr) return ToolModel::findFriendByAddress(linphoneAddr);
	else return nullptr;
}

std::shared_ptr<linphone::Friend> ToolModel::findFriendByAddress(std::shared_ptr<linphone::Address> linphoneAddr) {
	auto friendsManager = FriendsManager::getInstance();
	QString key = Utils::coreStringToAppString(linphoneAddr->asStringUriOnly());
	if (friendsManager->isInKnownFriends(key)) {
		//		qDebug() << key << "have been found in known friend, return it";
		return friendsManager->getKnownFriendAtKey(key);
	} else if (friendsManager->isInUnknownFriends(key)) {
		//		qDebug() << key << "have been found in unknown friend, return it";
		return friendsManager->getUnknownFriendAtKey(key);
	}
	auto f = CoreModel::getInstance()->getCore()->findFriend(linphoneAddr);
	if (f) {
		if (friendsManager->isInUnknownFriends(key)) {
			friendsManager->removeUnknownFriend(key);
		}
		//		qDebug() << "found friend, add to known map";
		friendsManager->appendKnownFriend(linphoneAddr, f);
	}
	if (!f) {
		if (friendsManager->isInOtherAddresses(key)) {
			//			qDebug() << "A magic search has already be done for address" << key << "and nothing was found,
			// return";
			return nullptr;
		}
		friendsManager->appendOtherAddress(key);
		//		qDebug() << "Couldn't find friend" << linphoneAddr->asStringUriOnly() << "in core, use magic search";
		CoreModel::getInstance()->searchInMagicSearch(Utils::coreStringToAppString(linphoneAddr->asStringUriOnly()),
		                                              (int)linphone::MagicSearch::Source::LdapServers |
		                                                  (int)linphone::MagicSearch::Source::RemoteCardDAV,
		                                              LinphoneEnums::MagicSearchAggregation::Friend, 50);
	}
	return f;
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
			//: "The calling address is not an interpretable SIP address : %1
			*errorMessage = tr("call_error_uninterpretable_sip_address").arg(sipAddress);
		}
		return false;
	}
	bool isConference = !!core->findConferenceInformationFromUri(address);
	if (isConference) mediaEncryption = linphone::MediaEncryption::ZRTP;

	if (SettingsModel::dndEnabled(core->getConfig())) { // Force tones for outgoing calls when in DND mode (ringback,
		                                                // dtmf, etc … ) disabled again when no more calls are running.
		SettingsModel::getInstance()->setCallToneIndicationsEnabled(true);
	}
	std::shared_ptr<linphone::CallParams> params = core->createCallParams(nullptr);
	CallModel::activateLocalVideo(params, localVideoEnabled);

	bool micEnabled = options.contains("microEnabled") ? options["microEnabled"].toBool() : true;
	params->enableMic(micEnabled);
	params->setMediaEncryption(mediaEncryption);
	if (Utils::coreStringToAppString(params->getRecordFile()).isEmpty()) {

		params->setRecordFile(
		    Paths::getCapturesDirPath()
		        .append(Utils::generateSavedFilename(QString::fromStdString(address->getUsername()), ""))
		        .append(".smff")
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

bool ToolModel::createGroupCall(QString subject, const std::list<QString> &participantAddresses, QString *message) {
	auto core = CoreModel::getInstance()->getCore();
	auto conferenceParams = core->createConferenceParams(nullptr);
	conferenceParams->enableVideo(true);
	auto account = core->getDefaultAccount();
	if (!account) {
		qWarning() << "No default account found, can't create group call";
		*message = tr("group_call_error_no_account");
		return false;
	}
	conferenceParams->setAccount(account);
	conferenceParams->setSubject(Utils::appStringToCoreString(subject));

	auto createEndToEnd = SettingsModel::getInstance()->getCreateEndToEndEncryptedMeetingsAndGroupCalls();
	conferenceParams->setSecurityLevel(createEndToEnd ? linphone::Conference::SecurityLevel::EndToEnd
	                                                  : linphone::Conference::SecurityLevel::PointToPoint);

	conferenceParams->enableChat(true);

	auto conference = core->createConferenceWithParams(conferenceParams);
	if (conference) {
		auto callParams = core->createCallParams(nullptr);
		callParams->enableVideo(true);
		callParams->setVideoDirection(linphone::MediaDirection::RecvOnly);
		std::list<std::shared_ptr<linphone::Address>> participants;
		for (auto &address : participantAddresses) {
			auto linAddr = ToolModel::interpretUrl(address);
			participants.push_back(linAddr);
		}
		auto status = conference->inviteParticipants(participants, callParams);
		if (status != 0) {
			qWarning() << "Failed to invite participants into group call";
			*message = tr("group_call_error_participants_invite");
		}
	} else {
		qWarning() << "Could not create group call";
		*message = tr("group_call_error_creation");
	}
	return conference != nullptr;
}

std::shared_ptr<linphone::Account> ToolModel::findAccount(const std::shared_ptr<const linphone::Address> &address) {
	std::shared_ptr<linphone::Account> account;
	for (auto item : CoreModel::getInstance()->getCore()->getAccountList()) {
		if (item->getParams() && item->getParams()->getIdentityAddress()->weakEqual(address)) {
			account = item;
			break;
		}
	}
	return account;
}

std::shared_ptr<linphone::Account> ToolModel::findAccount(const QString &address) {
	auto linAddr = ToolModel::interpretUrl(address);
	return findAccount(linAddr);
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

bool ToolModel::isLocal(const std::shared_ptr<linphone::Conference> &conference,
                        const std::shared_ptr<const linphone::ParticipantDevice> &device) {
	auto deviceAddress = device->getAddress();
	auto callAddress = conference->getMe()->getAddress();
	auto gruuAddress = findAccount(callAddress)->getContactAddress();
	return deviceAddress->equal(gruuAddress);
}

bool ToolModel::isMe(const QString &address) {
	bool isMe = false;
	auto linAddr = ToolModel::interpretUrl(address);
	auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	if (!defaultAccount) {
		for (auto &account : CoreModel::getInstance()->getCore()->getAccountList()) {
			if (account->getContactAddress()->weakEqual(linAddr)) return true;
		}
	} else {
		auto accountAddr = defaultAccount->getContactAddress();
		isMe = linAddr && accountAddr ? accountAddr->weakEqual(linAddr) : false;
	}
	return isMe;
}

bool ToolModel::isMe(const std::shared_ptr<const linphone::Address> &address) {
	auto currentAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
	if (!currentAccount) { // Default account is selected : Me is all local accounts.
		return findAccount(address) != nullptr;
	} else return address ? currentAccount->getContactAddress()->weakEqual(address) : false;
}

std::shared_ptr<linphone::FriendList> ToolModel::getFriendList(const std::string &listName) {
	auto core = CoreModel::getInstance()->getCore();
	auto friendList = core->getFriendListByName(listName);
	if (!friendList) {
		friendList = core->createFriendList();
		friendList->setDisplayName(listName);
		if (listName == "ldap_friends") {
			friendList->setType(linphone::FriendList::Type::ApplicationCache);
		}
		core->addFriendList(friendList);
	}
	return friendList;
}

std::shared_ptr<linphone::FriendList> ToolModel::getAppFriendList() {
	return getFriendList("app_friends");
}

std::shared_ptr<linphone::FriendList> ToolModel::getLdapFriendList() {
	return getFriendList("ldap_friends");
}

bool ToolModel::friendIsInFriendList(const std::shared_ptr<linphone::FriendList> &friendList,
                                     const std::shared_ptr<linphone::Friend> &f) {
	auto friends = friendList->getFriends();
	auto it = std::find_if(friends.begin(), friends.end(),
	                       [f](std::shared_ptr<linphone::Friend> linFriend) { return linFriend == f; });
	return (it != friends.end());
}

QString ToolModel::getMessageFromContent(std::list<std::shared_ptr<linphone::Content>> contents) {
	for (auto &content : contents) {
		if (content->isText()) {
			return Utils::coreStringToAppString(content->getUtf8Text());
		} else if (content->isFile()) {
			return Utils::coreStringToAppString(content->getName());
		} else if (content->isIcalendar()) {
			return QString("Invitation à une réunion");
		} else if (content->isMultipart()) {
			return getMessageFromContent(content->getParts());
		}
	}
	return QString("");
}

// Load downloaded codecs like OpenH264 (needs to be after core is created and has loaded its plugins, as
// reloadMsPlugins modifies plugin path for the factory)
void ToolModel::loadDownloadedCodecs() {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
#if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
	qInfo() << QStringLiteral("Loading downloaded codecs in folder %1…").arg(Paths::getCodecsDirPath());
	QDirIterator it(Paths::getCodecsDirPath());
	while (it.hasNext()) {
		QFileInfo info(it.next());
		const QString filename(info.fileName());
		if (QLibrary::isLibrary(filename)) {
			qInfo() << QStringLiteral("Loading `%1` symbols…").arg(filename);
			auto library = QLibrary(info.filePath());
			if (!library.load()) // lib.load())
				qWarning() << QStringLiteral("Failed to load `%1` symbols.").arg(filename) << library.errorString();
			else qInfo() << QStringLiteral("Loaded `%1` symbols…").arg(filename);
		} else qWarning() << QStringLiteral("Found codec file `%1` that is not a library").arg(filename);
	}
	CoreModel::getInstance()->getCore()->reloadMsPlugins("");
	qInfo() << QStringLiteral("Finished loading downloaded codecs.");
#endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
}

// Removes .in suffix from downloaded updates.
// Updates are downloaded with .in suffix as they can't overwrite already loaded plugin
// they are loaded at next app startup.

void ToolModel::updateCodecs() {
	mustBeInLinphoneThread(sLog().arg(Q_FUNC_INFO));
#if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
	static const QString codecSuffix = QStringLiteral(".%1").arg(Constants::LibraryExtension);

	QDirIterator it(Paths::getCodecsDirPath());
	while (it.hasNext()) {
		QFileInfo info(it.next());
		if (info.suffix() == QLatin1String("in")) {
			QString codecName = info.completeBaseName();
			if (codecName.endsWith(codecSuffix)) {
				QString codecPath = info.dir().path() + QDir::separator() + codecName;
				QFile::remove(codecPath);
				QFile::rename(info.filePath(), codecPath);
			}
		}
	}
#endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
}

QVariantMap ToolModel::createVariant(const std::shared_ptr<const linphone::AudioDevice> &device) {
	QVariantMap map;
	map.insert("id", device ? Utils::coreStringToAppString(device->getId()) : "");
	map.insert("display_name",
	           device ? Utils::coreStringToAppString(device->getDriverName() + ": " + device->getDeviceName())
	                  //: "Unknown device"
	                  : tr("unknown_audio_device_name"));
	return map;
}

// User agent

QString ToolModel::computeUserAgent(const std::shared_ptr<linphone::Config> &config) {
	return QStringLiteral("%1 (%2) %3 Qt/%4 LinphoneSDK")
	    .arg(Utils::getApplicationProduct())
	    .arg(SettingsModel::getDeviceName(config).replace('\\', "\\\\").replace('(', "\\(").replace(')', "\\)"))
	    .arg(Utils::getOsProduct())
	    .arg(qVersion())
	    .remove("'");
}

std::shared_ptr<linphone::ConferenceParams>
ToolModel::getChatRoomParams(std::shared_ptr<linphone::Call> call, std::shared_ptr<linphone::Address> remoteAddress) {
	auto core = call ? call->getCore() : CoreModel::getInstance()->getCore();
	auto localAddress = call ? call->getCallLog()->getLocalAddress() : nullptr;
	if (!remoteAddress && call) remoteAddress = call->getRemoteAddress()->clone();
	auto account = findAccount(localAddress);
	if (!account) account = core->getDefaultAccount();
	if (!account) qWarning() << "failed to get account, return";
	if (!account) return nullptr;

	auto params = core->createConferenceParams(call ? call->getConference() : nullptr);
	params->enableChat(true);
	params->enableGroup(false);
	//: Dummy subject
	params->setSubject(Utils::appStringToCoreString(QObject::tr("chat_dummy_subject")));
	params->setAccount(account);

	auto chatParams = params->getChatParams();
	if (!chatParams) {
		qWarning() << "failed to get chat params from conference params, return";
		return nullptr;
	}
	chatParams->setEphemeralLifetime(0);
	auto accountParams = account->getParams();
	auto sameDomain = remoteAddress && remoteAddress->getDomain() == SettingsModel::getInstance()->getDefaultDomain() &&
	                  remoteAddress->getDomain() == accountParams->getDomain();
	if (accountParams->getInstantMessagingEncryptionMandatory() && sameDomain) {
		qDebug() << "Account is in secure mode & domain matches, requesting E2E encryption";
		chatParams->setBackend(linphone::ChatRoom::Backend::FlexisipChat);
		params->setSecurityLevel(linphone::Conference::SecurityLevel::EndToEnd);
	} else if (!accountParams->getInstantMessagingEncryptionMandatory()) {
		if (SettingsModel::getInstance()->getCreateEndToEndEncryptedMeetingsAndGroupCalls()) {
			qDebug() << "Account is in interop mode but LIME is available, requesting E2E encryption";
			chatParams->setBackend(linphone::ChatRoom::Backend::FlexisipChat);
			params->setSecurityLevel(linphone::Conference::SecurityLevel::EndToEnd);
		} else {
			qDebug() << "Account is in interop mode and LIME is available, disabling E2E encryption";
			chatParams->setBackend(linphone::ChatRoom::Backend::Basic);
			params->setSecurityLevel(linphone::Conference::SecurityLevel::None);
		}
	} else {
		qDebug() << "Account is in secure mode, can't chat with SIP address of different domain";
		return nullptr;
	}
	return params;
}

std::shared_ptr<linphone::ChatRoom> ToolModel::lookupCurrentCallChat(std::shared_ptr<CallModel> callModel) {
	auto call = callModel->getMonitor();
	auto conference = callModel->getConference();
	if (conference) {
		return conference->getChatRoom();
	} else {
		auto core = CoreModel::getInstance()->getCore();
		auto params = getChatRoomParams(call);
		auto remoteaddress = call->getRemoteAddress();
		auto localAddress = call->getCallLog()->getLocalAddress();
		std::list<std::shared_ptr<linphone::Address>> participants;
		participants.push_back(remoteaddress->clone());
		qDebug() << "Looking for chat with local address" << localAddress->asStringUriOnly() << "and participant"
		         << remoteaddress->asStringUriOnly();
		auto existingChat = core->searchChatRoom(params, localAddress, nullptr, participants);
		if (existingChat) qDebug() << "Found existing chat";
		else qDebug() << "Did not find existing chat";
		return existingChat;
	}
}

std::shared_ptr<linphone::ChatRoom> ToolModel::createCurrentCallChat(std::shared_ptr<CallModel> callModel) {
	auto call = callModel->getMonitor();
	auto remoteAddress = call->getRemoteAddress();
	std::list<std::shared_ptr<linphone::Address>> participants;
	participants.push_back(remoteAddress->clone());
	auto core = CoreModel::getInstance()->getCore();
	auto params = getChatRoomParams(call);
	if (!params) {
		qWarning() << "failed to create chatroom params for call with" << remoteAddress->asStringUriOnly();
		return nullptr;
	}
	auto chatRoom = core->createChatRoom(params, participants);
	return chatRoom;
}

std::shared_ptr<linphone::ChatRoom> ToolModel::lookupChatForAddress(std::shared_ptr<linphone::Address> remoteAddress) {
	auto core = CoreModel::getInstance()->getCore();
	auto account = core->getDefaultAccount();
	if (!account) return nullptr;
	auto localAddress = account->getParams()->getIdentityAddress();
	if (!localAddress || !remoteAddress) return nullptr;

	auto params = getChatRoomParams(nullptr, remoteAddress);
	std::list<std::shared_ptr<linphone::Address>> participants;
	participants.push_back(remoteAddress->clone());

	qDebug() << "Looking for chat with local address" << localAddress->asStringUriOnly() << "and participant"
	         << remoteAddress->asStringUriOnly();
	auto existingChat = core->searchChatRoom(params, localAddress, nullptr, participants);
	if (existingChat) qDebug() << "Found existing chat";
	else qDebug() << "Did not find existing chat";
	return existingChat;
}

std::shared_ptr<linphone::ChatRoom> ToolModel::createChatForAddress(std::shared_ptr<linphone::Address> remoteAddress) {
	std::list<std::shared_ptr<linphone::Address>> participants;
	participants.push_back(remoteAddress->clone());
	auto core = CoreModel::getInstance()->getCore();
	auto params = getChatRoomParams(nullptr, remoteAddress);
	if (!params) {
		qWarning() << "failed to create chatroom params for address" << remoteAddress->asStringUriOnly();
		return nullptr;
	}
	auto chatRoom = core->createChatRoom(params, participants);
	return chatRoom;
}