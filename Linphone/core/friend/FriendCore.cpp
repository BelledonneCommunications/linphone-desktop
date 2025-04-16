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

#include "FriendCore.hpp"
#include "core/App.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(FriendCore)

// Translation does not work if not in class directly
//: "Adresse SIP"
const QString _addressLabel = FriendCore::tr("sip_address");
//: "Téléphone"
const QString _phoneLabel = FriendCore::tr("device_id");

QSharedPointer<FriendCore>
FriendCore::create(const std::shared_ptr<linphone::Friend> &contact, bool isStored, int sourceFlags) {
	auto sharedPointer =
	    QSharedPointer<FriendCore>(new FriendCore(contact, isStored, sourceFlags), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

FriendCore::FriendCore(const std::shared_ptr<linphone::Friend> &contact, bool isStored, int sourceFlags)
    : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	if (contact) {
		mustBeInLinphoneThread(getClassName());
		mFriendModel = Utils::makeQObject_ptr<FriendModel>(contact);
		mFriendModel->setSelf(mFriendModel);
		mConsolidatedPresence = LinphoneEnums::fromLinphone(contact->getConsolidatedPresence());
		mPresenceTimestamp = mFriendModel->getPresenceTimestamp();
		mPictureUri = Utils::coreStringToAppString(contact->getPhoto());
		mFullName = mFriendModel->getFullName();
		auto defaultAddress = contact->getAddress();
		auto vcard = contact->getVcard();
		if (vcard) {
			mOrganization = Utils::coreStringToAppString(vcard->getOrganization());
			mJob = Utils::coreStringToAppString(vcard->getJobTitle());
			mGivenName = Utils::coreStringToAppString(vcard->getGivenName());
			mFamilyName = Utils::coreStringToAppString(vcard->getFamilyName());
			mVCardString = Utils::coreStringToAppString(vcard->asVcard4String());
		}

		auto addresses = contact->getAddresses();
		for (auto &address : addresses) {
			mAddressList.append(Utils::createFriendAddressVariant(
				tr("sip_address"), Utils::coreStringToAppString(address->asStringUriOnly())));
		}
		mDefaultAddress = defaultAddress ? Utils::coreStringToAppString(defaultAddress->asStringUriOnly()) : QString();
		mDefaultFullAddress = defaultAddress ? Utils::coreStringToAppString(defaultAddress->asString()) : QString();
		// lDebug() << mDefaultAddress << " / " << mDefaultFullAddress;
		auto phoneNumbers = contact->getPhoneNumbersWithLabel();
		for (auto &phoneNumber : phoneNumbers) {
			auto label = Utils::coreStringToAppString(phoneNumber->getLabel());
			if (label.isEmpty()) label = tr("device_id");
			mPhoneNumberList.append(
			    Utils::createFriendAddressVariant(label, Utils::coreStringToAppString(phoneNumber->getPhoneNumber())));
		}

		auto devices = contact->getDevices();
		for (auto &device : devices) {
			mDeviceList.append(
			    Utils::createFriendDeviceVariant(Utils::coreStringToAppString(device->getDisplayName()),
			                                     // do not use uri only as we want the unique device
			                                     Utils::coreStringToAppString(device->getAddress()->asString()),
			                                     LinphoneEnums::fromLinphone(device->getSecurityLevel())));
		}
		updateVerifiedDevicesCount();
		mStarred = contact->getStarred();
		mIsSaved = true;
		mIsStored = isStored;
		mIsLdap = ToolModel::friendIsInFriendList(ToolModel::getLdapFriendList(), contact);
		mIsCardDAV = (sourceFlags & (int)linphone::MagicSearch::Source::RemoteCardDAV) != 0;
		mIsAppFriend = ToolModel::friendIsInFriendList(ToolModel::getAppFriendList(), contact);
	} else {
		mIsSaved = false;
		mStarred = false;
		mIsStored = false;
		mIsLdap = false;
		mIsCardDAV = false;
	}

	connect(this, &FriendCore::addressChanged, &FriendCore::allAddressesChanged);
	connect(this, &FriendCore::phoneNumberChanged, &FriendCore::allAddressesChanged);
}

FriendCore::FriendCore(const FriendCore &friendCore) {
	// Only copy friend values without models for lambda using and avoid concurrencies.
	mAddressList = friendCore.mAddressList;
	mPhoneNumberList = friendCore.mPhoneNumberList;
	mDefaultAddress = friendCore.mDefaultAddress;
	mDefaultFullAddress = friendCore.mDefaultFullAddress;
	mGivenName = friendCore.mGivenName;
	mFamilyName = friendCore.mFamilyName;
	mFullName = friendCore.mFullName;
	mOrganization = friendCore.mOrganization;
	mJob = friendCore.mJob;
	mPictureUri = friendCore.mPictureUri;
	mIsSaved = friendCore.mIsSaved;
	mIsStored = friendCore.mIsStored;
	mIsLdap = friendCore.mIsLdap;
	mIsAppFriend = friendCore.mIsAppFriend;
	mIsCardDAV = friendCore.mIsCardDAV;
}

FriendCore::~FriendCore() {
	mustBeInMainThread("~" + getClassName());
	if (mFriendModel) emit mFriendModel->removeListener();
}

void FriendCore::setSelf(SafeSharedPointer<FriendCore> me) {
	setSelf(me.mQDataWeak.lock());
}
void FriendCore::setSelf(QSharedPointer<FriendCore> me) {
	if (me) {
		if (mFriendModel) {
			mFriendModelConnection = SafeConnection<FriendCore, FriendModel>::create(me, mFriendModel);
			mFriendModelConnection->makeConnectToModel(&FriendModel::updated, [this]() {
				mFriendModelConnection->invokeToCore([this]() { emit friendUpdated(); });
			});
			mFriendModelConnection->makeConnectToModel(
			    &FriendModel::removed, [this]() { mFriendModelConnection->invokeToCore([this]() { removed(this); }); });
			mFriendModelConnection->makeConnectToModel(
			    &FriendModel::presenceReceived,
			    [this](LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp) {
				    auto devices = mFriendModel->getDevices();
				    QVariantList devicesList;
				    for (auto &device : devices) {
					    devicesList.append(Utils::createFriendDeviceVariant(
					        Utils::coreStringToAppString(device->getDisplayName()),
					        // do not use uri only as we want the unique device
					        Utils::coreStringToAppString(device->getAddress()->asString()),
					        LinphoneEnums::fromLinphone(device->getSecurityLevel())));
				    }
				    mFriendModelConnection->invokeToCore(
				        [this, consolidatedPresence, presenceTimestamp, devicesList]() {
					        setConsolidatedPresence(consolidatedPresence);
					        setPresenceTimestamp(presenceTimestamp);

					        setDevices(devicesList);
					        updateVerifiedDevicesCount();
				        });
			    });
			mFriendModelConnection->makeConnectToModel(&FriendModel::pictureUriChanged, [this](const QString &uri) {
				mFriendModelConnection->invokeToCore([this, uri]() { this->onPictureUriChanged(uri); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::starredChanged, [this](bool starred) {
				mFriendModelConnection->invokeToCore([this, starred]() { this->onStarredChanged(starred); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::givenNameChanged, [this](const QString &name) {
				mFriendModelConnection->invokeToCore([this, name]() { setGivenName(name); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::familyNameChanged, [this](const QString &name) {
				mFriendModelConnection->invokeToCore([this, name]() { setFamilyName(name); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::organizationChanged, [this](const QString &orga) {
				mFriendModelConnection->invokeToCore([this, orga]() { setOrganization(orga); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::fullNameChanged, [this](const QString &name) {
				mFriendModelConnection->invokeToCore([this, name]() { setFullName(name); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::jobChanged, [this](const QString &job) {
				mFriendModelConnection->invokeToCore([this, job]() { setJob(job); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::addressesChanged, [this]() {
				auto numbers = mFriendModel->getAddresses();
				QList<QVariant> addr;
				for (auto &num : numbers) {
					addr.append(Utils::createFriendAddressVariant(
						tr("sip_address"), Utils::coreStringToAppString(num->asStringUriOnly())));
				}
				mFriendModelConnection->invokeToCore([this, addr]() { resetPhoneNumbers(addr); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::phoneNumbersChanged, [this]() {
				auto numbers = mFriendModel->getPhoneNumbers();
				QList<QVariant> addr;
				for (auto &num : numbers) {
					addr.append(Utils::createFriendAddressVariant(tr("device_id"),
					                                              Utils::coreStringToAppString(num->getPhoneNumber())));
				}
				mFriendModelConnection->invokeToCore([this, addr]() { resetPhoneNumbers(addr); });
			});
			mFriendModelConnection->makeConnectToModel(
			    &FriendModel::objectNameChanged,
			    [this](const QString &objectName) { lDebug() << "object name changed" << objectName; });

			// From GUI
			mFriendModelConnection->makeConnectToCore(&FriendCore::lSetStarred, [this](bool starred) {
				mFriendModelConnection->invokeToModel([this, starred]() { mFriendModel->setStarred(starred); });
			});
			if (!mCoreModelConnection) {
				mCoreModelConnection = SafeConnection<FriendCore, CoreModel>::create(me, CoreModel::getInstance());
			}
			mCoreModelConnection->makeConnectToModel(
			    &CoreModel::callStateChanged,
			    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Call> &call,
			           linphone::Call::State state, const std::string &message) {
				    if (state != linphone::Call::State::End && state != linphone::Call::State::Released) return;
				    auto devices = mFriendModel->getDevices();
				    QVariantList devicesList;
				    for (auto &device : devices) {
					    devicesList.append(Utils::createFriendDeviceVariant(
					        Utils::coreStringToAppString(device->getDisplayName()),
					        // do not use uri only as we want the unique device
					        Utils::coreStringToAppString(device->getAddress()->asString()),
					        LinphoneEnums::fromLinphone(device->getSecurityLevel())));
				    }
				    mCoreModelConnection->invokeToCore([this, devicesList]() {
					    setDevices(devicesList);
					    updateVerifiedDevicesCount();
				    });
			    });
			mCoreModelConnection->makeConnectToCore(&FriendCore::saved, [this]() {
				mCoreModelConnection->invokeToModel(
				    [this, f = mFriendModel->getFriend()]() { emit CoreModel::getInstance()->friendUpdated(f); });
			});

		} else { // Create
			mCoreModelConnection = SafeConnection<FriendCore, CoreModel>::create(me, CoreModel::getInstance());
		}
	}
}

void FriendCore::reset(const FriendCore &contact) {
	resetAddresses(contact.getAddresses());
	resetPhoneNumbers(contact.getPhoneNumbers());
	setDefaultAddress(contact.getDefaultAddress());
	setDefaultFullAddress(contact.getDefaultFullAddress());
	setGivenName(contact.getGivenName());
	setFamilyName(contact.getFamilyName());
	setOrganization(contact.getOrganization());
	setFullName(contact.getFullName());
	setJob(contact.getJob());
	setPictureUri(contact.getPictureUri());
	setIsSaved(mFriendModel != nullptr);
}

QString FriendCore::getFullName() const {
	return mFullName;
}

void FriendCore::setFullName(const QString &name) {
	if (mFullName != name) {
		mFullName = name.simplified();
		emit fullNameChanged(name);
		setIsSaved(false);
	}
}

QString FriendCore::getGivenName() const {
	return mGivenName;
}

void FriendCore::setGivenName(const QString &name) {
	if (mGivenName != name) {
		mGivenName = name.simplified();
		emit givenNameChanged(name);
		setIsSaved(false);
	}
}

QString FriendCore::getOrganization() const {
	return mOrganization;
}

void FriendCore::setOrganization(const QString &orga) {
	if (mOrganization != orga) {
		mOrganization = orga;
		emit organizationChanged();
		setIsSaved(false);
	}
}

QString FriendCore::getJob() const {
	return mJob;
}

void FriendCore::setJob(const QString &job) {
	if (mJob != job) {
		mJob = job;
		emit jobChanged();
		setIsSaved(false);
	}
}

QString FriendCore::getFamilyName() const {
	return mFamilyName;
}

void FriendCore::setFamilyName(const QString &name) {
	if (mFamilyName != name) {
		mFamilyName = name.simplified();
		emit familyNameChanged(name);
		setIsSaved(false);
	}
}

bool FriendCore::getStarred() const {
	return mStarred;
}

void FriendCore::onStarredChanged(bool starred) {
	mStarred = starred;
	save();
	emit starredChanged();
}

QString FriendCore::getVCard() const {
	return mVCardString;
}

QList<QVariant> FriendCore::getPhoneNumbers() const {
	return mPhoneNumberList;
}

QVariant FriendCore::getPhoneNumberAt(int index) const {
	if (index < 0 || index >= mPhoneNumberList.count()) return QVariant();
	return mPhoneNumberList[index];
}

void FriendCore::setPhoneNumberAt(int index, const QString &label, const QString &phoneNumber) {
	if (index < 0 || index >= mPhoneNumberList.count()) return;
	auto map = mPhoneNumberList[index].toMap();
	auto oldLabel = map["label"].toString();
	if (/*oldLabel != label || */ map["address"] != phoneNumber) {
		mPhoneNumberList.replace(index,
		                         Utils::createFriendAddressVariant(label.isEmpty() ? oldLabel : label, phoneNumber));
		emit phoneNumberChanged();
		setIsSaved(false);
	}
}

void FriendCore::removePhoneNumber(int index) {
	if (index != -1) mPhoneNumberList.remove(index);
	emit phoneNumberChanged();
	setIsSaved(false);
}

void FriendCore::appendPhoneNumber(const QString &label, const QString &number) {
	mPhoneNumberList.append(Utils::createFriendAddressVariant(label, number));
	emit phoneNumberChanged();
	setIsSaved(false);
}

void FriendCore::resetPhoneNumbers(QList<QVariant> newList) {
	mPhoneNumberList = newList;
	emit phoneNumberChanged();
}

QList<QVariant> FriendCore::getAddresses() const {
	return mAddressList;
}

QVariant FriendCore::getAddressAt(int index) const {
	if (index < 0 || index >= mAddressList.count()) return QVariant();
	return mAddressList[index];
}

void FriendCore::setAddressAt(int index, QString label, QString address) {
	if (index < 0 || index >= mAddressList.count()) return;
	auto map = mAddressList[index].toMap();
	label = label.isEmpty() ? map["label"].toString() : label;
	QString currentAddress = map["address"].toString();

	if (Utils::isUsername(address)) {
		mCoreModelConnection->invokeToModel([this, index, label, currentAddress, address]() {
			auto linphoneAddr = ToolModel::interpretUrl(address);
			QString interpretedAddr = Utils::coreStringToAppString(linphoneAddr->asStringUriOnly());
			if (interpretedAddr != currentAddress) {
				mCoreModelConnection->invokeToCore([this, index, label, interpretedAddr]() {
					mAddressList.replace(index, Utils::createFriendAddressVariant(label, interpretedAddr));
					emit addressChanged();
					setIsSaved(false);
				});
			}
		});
	} else if (address != currentAddress) {
		mAddressList.replace(index, Utils::createFriendAddressVariant(label, address));
		emit addressChanged();
		setIsSaved(false);
	}
}

void FriendCore::removeAddress(int index) {
	if (index < 0 && index >= mAddressList.size()) return;
	auto map = mAddressList[index].toMap();
	if (map["address"].toString() == mDefaultFullAddress) mDefaultFullAddress.clear();
	if (map["address"].toString() == mDefaultAddress) mDefaultAddress.clear();
	mAddressList.remove(index);
	emit addressChanged();
	setIsSaved(false);
}

void FriendCore::appendAddress(const QString &addr) {
	if (addr.isEmpty()) return;
	mCoreModelConnection->invokeToModel([this, addr]() {
		auto linphoneAddr = ToolModel::interpretUrl(addr);
		QString interpretedFullAddress = linphoneAddr ? Utils::coreStringToAppString(linphoneAddr->asString()) : "";
		QString interpretedAddress = linphoneAddr ? Utils::coreStringToAppString(linphoneAddr->asStringUriOnly()) : "";
		mCoreModelConnection->invokeToCore([this, interpretedAddress, interpretedFullAddress]() {
			if (interpretedAddress.isEmpty()) Utils::showInformationPopup(tr("information_popup_error_title"),
																		  //: "Adresse invalide"
																		  tr("information_popup_invalid_address_message"), false);
			else {
				mAddressList.append(Utils::createFriendAddressVariant(tr("sip_address"), interpretedAddress));
				if (mDefaultFullAddress.isEmpty()) mDefaultFullAddress = interpretedFullAddress;
				if (mDefaultAddress.isEmpty()) mDefaultAddress = interpretedAddress;
				emit addressChanged();
				setIsSaved(false);
			}
		});
	});
}

void FriendCore::resetAddresses(QList<QVariant> newList) {
	mAddressList = newList;
	emit addressChanged();
}

// Display all sip addresses and remove phone numbers duplicates (priority on sip)
QList<QVariant> FriendCore::getAllAddresses() const {
	QList<QVariant> addresses;
	auto addressIt = mAddressList.begin();
	auto phoneNumbers = mPhoneNumberList;
	while (addressIt != mAddressList.end()) {
		auto username = Utils::getUsername(addressIt->toMap()["address"].toString());
		std::remove_if(phoneNumbers.begin(), phoneNumbers.end(),
		               [username](const QVariant &data) { return data.toMap()["address"].toString() == username; });
		++addressIt;
	}
	addresses << phoneNumbers;
	addresses << mAddressList;
	return addresses;
}

QList<QVariant> FriendCore::getDevices() const {
	return mDeviceList;
}

void FriendCore::updateVerifiedDevicesCount() {
	mVerifiedDeviceCount = 0;
	for (auto &device : mDeviceList) {
		auto map = device.toMap();
		if (map["securityLevel"].value<LinphoneEnums::SecurityLevel>() ==
		    LinphoneEnums::SecurityLevel::EndToEndEncryptedAndVerified)
			++mVerifiedDeviceCount;
	}
	emit verifiedDevicesChanged();
}

void FriendCore::setDevices(QVariantList devices) {
	mDeviceList.clear();
	mDeviceList.append(devices);
	emit devicesChanged();
}

LinphoneEnums::SecurityLevel FriendCore::getSecurityLevelForAddress(const QString &address) const {
	for (auto &device : mDeviceList) {
		auto map = device.toMap();
		if (map["address"].toString() == address) {
			return map["securityLevel"].value<LinphoneEnums::SecurityLevel>();
		}
	}
	return LinphoneEnums::SecurityLevel::None;
}

QString FriendCore::getDefaultFullAddress() const {
	return mDefaultFullAddress;
}

void FriendCore::setDefaultFullAddress(const QString &address) {
	if (mDefaultFullAddress != address) {
		mDefaultFullAddress = address;
		emit defaultFullAddressChanged();
	}
}

QString FriendCore::getDefaultAddress() const {
	return mDefaultAddress;
}

void FriendCore::setDefaultAddress(const QString &address) {
	if (mDefaultAddress != address) {
		mDefaultAddress = address;
		emit defaultAddressChanged();
	}
}

LinphoneEnums::ConsolidatedPresence FriendCore::getConsolidatedPresence() const {
	return mConsolidatedPresence;
}

void FriendCore::setConsolidatedPresence(LinphoneEnums::ConsolidatedPresence presence) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mConsolidatedPresence != presence) {
		mConsolidatedPresence = presence;
		emit consolidatedPresenceChanged(mConsolidatedPresence);
	}
}

QDateTime FriendCore::getPresenceTimestamp() const {
	return mPresenceTimestamp;
}

void FriendCore::setPresenceTimestamp(QDateTime presenceTimestamp) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (mPresenceTimestamp != presenceTimestamp) {
		mPresenceTimestamp = presenceTimestamp;
		emit presenceTimestampChanged(mPresenceTimestamp);
	}
}

QString FriendCore::getPictureUri() const {
	return mPictureUri;
}

void FriendCore::setPictureUri(const QString &uri) {
	if (mPictureUri != uri) {
		mPictureUri = uri;
		emit pictureUriChanged();
		setIsSaved(false);
	}
}

void FriendCore::onPictureUriChanged(QString uri) {
	mPictureUri = uri;
	emit pictureUriChanged();
}

bool FriendCore::getIsSaved() const {
	return mIsSaved;
}
void FriendCore::setIsSaved(bool data) {
	if (mIsSaved != data) {
		mIsSaved = data;
		if (mIsSaved) setIsStored(true);
		emit isSavedChanged(mIsSaved);
	}
}

bool FriendCore::getIsStored() const {
	return mIsStored;
}
void FriendCore::setIsStored(bool data) {
	if (mIsStored != data) {
		mIsStored = data;
		emit isStoredChanged();
	}
}

void FriendCore::writeIntoModel(std::shared_ptr<FriendModel> model) const {
	mustBeInLinphoneThread(QString("[") + gClassName + "] " + Q_FUNC_INFO);
	model->getFriend()->edit();
	// needed to create the vcard if not created yet
	auto name = mGivenName + (mFamilyName.isEmpty() || mGivenName.isEmpty() ? "" : " ") + mFamilyName;
	model->setName(name.isEmpty() ? (mFullName.isEmpty() ? mOrganization : mFullName) : name);
	auto core = CoreModel::getInstance()->getCore();

	std::list<std::shared_ptr<linphone::Address>> addresses;
	for (auto &addr : mAddressList) {
		auto friendAddress = addr.toMap();
		auto address =
		    linphone::Factory::get()->createAddress(Utils::appStringToCoreString(friendAddress["address"].toString()));
		addresses.push_back(address);
	}
	model->resetAddresses(addresses);

	model->setAddress(ToolModel::interpretUrl(mDefaultFullAddress));

	std::list<std::shared_ptr<linphone::FriendPhoneNumber>> phones;
	for (auto &number : mPhoneNumberList) {
		auto friendAddress = number.toMap();
		auto num = linphone::Factory::get()->createFriendPhoneNumber(
		    Utils::appStringToCoreString(friendAddress["address"].toString()),
		    Utils::appStringToCoreString(friendAddress["label"].toString()));
		phones.push_back(num);
	}
	model->resetPhoneNumbers(phones);
	model->setGivenName(mGivenName);
	model->setFamilyName(mFamilyName);
	model->setOrganization(mOrganization);
	model->setFullName(mFullName);
	model->setJob(mJob);
	model->setPictureUri(mPictureUri);
	model->getFriend()->done();
	emit model->updated();
}

void FriendCore::writeFromModel(const std::shared_ptr<FriendModel> &model) {
	mustBeInLinphoneThread(QString("[") + gClassName + "] " + Q_FUNC_INFO);

	QList<QVariant> addresses;
	for (auto &addr : model->getAddresses()) {
		addresses.append(
			Utils::createFriendAddressVariant(tr("sip_address"), Utils::coreStringToAppString(addr->asStringUriOnly())));
	}
	mAddressList = addresses;
	mDefaultAddress = model->getDefaultAddress();
	mDefaultFullAddress = model->getDefaultFullAddress();

	QList<QVariant> phones;
	for (auto &number : model->getPhoneNumbers()) {
		phones.append(Utils::createFriendAddressVariant(Utils::coreStringToAppString(number->getLabel()),
		                                                Utils::coreStringToAppString(number->getPhoneNumber())));
	}
	mPhoneNumberList = phones;
	mGivenName = model->getGivenName();
	mFamilyName = model->getFamilyName();
	mOrganization = model->getOrganization();
	mJob = model->getJob();
	mPictureUri = model->getPictureUri();
}

void FriendCore::remove() {
	if (mFriendModel) { // Update
		mFriendModelConnection->invokeToModel([this]() { mFriendModel->remove(); });
	}
}

void FriendCore::save() { // Save Values to model
	mustBeInMainThread(getClassName() + "::save()");
	if (mAddressList.size() > 0) {
		auto it = std::find_if(mAddressList.begin(), mAddressList.end(), [this](const QVariant &a) {
			return a.toMap()["address"].toString() == mDefaultFullAddress;
		});
		if (it == mAddressList.end()) {
			mDefaultFullAddress = mAddressList[0].toMap()["address"].toString();
			emit defaultFullAddressChanged();
		}
	} else {
		mDefaultFullAddress = "";
		emit defaultFullAddressChanged();
	}
	FriendCore *thisCopy = new FriendCore(*this); // Pointer to avoid multiple copies in lambdas
	if (mFriendModel) {
		mFriendModelConnection->invokeToModel([this, thisCopy]() { // Copy values to avoid concurrency
			mustBeInLinphoneThread(getClassName() + "::save()");
			thisCopy->writeIntoModel(mFriendModel);
			thisCopy->deleteLater();
			mVCardString = mFriendModel->getVCardAsString();
			mFriendModelConnection->invokeToCore([this]() {
				setIsSaved(true);
				emit saved();
			});
		});
	} else {
		mCoreModelConnection->invokeToModel([this, thisCopy]() {
			std::shared_ptr<linphone::Friend> contact;
			auto core = CoreModel::getInstance()->getCore();
			auto appFriends = ToolModel::getAppFriendList();
			for (auto &addr : mAddressList) {
				auto friendAddress = addr.toMap();
				auto linphoneAddr = ToolModel::interpretUrl(friendAddress["address"].toString());
				contact = appFriends->findFriendByAddress(linphoneAddr);
				if (contact) break;
			}
			if (contact != nullptr) {
				auto friendModel = Utils::makeQObject_ptr<FriendModel>(contact);
				friendModel->setSelf(friendModel);
				mCoreModelConnection->invokeToCore([this, thisCopy, friendModel, contact] {
					mFriendModel = friendModel;
					mCoreModelConnection->invokeToModel([this, thisCopy, contact] {
						thisCopy->writeIntoModel(mFriendModel);
						thisCopy->deleteLater();
						mVCardString = mFriendModel->getVCardAsString();
						emit CoreModel::getInstance()->friendUpdated(contact);
						mCoreModelConnection->invokeToCore([this] {
							setIsSaved(true);
							emit saved();
						});
					});
				});
			} else {
				auto contact = core->createFriend();
				auto friendModel = Utils::makeQObject_ptr<FriendModel>(contact);
				friendModel->setSelf(friendModel);
				mCoreModelConnection->invokeToCore([this, thisCopy, friendModel, contact] {
					mFriendModel = friendModel;
					mCoreModelConnection->invokeToModel([this, thisCopy, contact] {
						auto core = CoreModel::getInstance()->getCore();
						thisCopy->writeIntoModel(mFriendModel);
						thisCopy->deleteLater();
						mVCardString = mFriendModel->getVCardAsString();
						auto carddavListForNewFriends = SettingsModel::getCardDAVListForNewFriends();
						auto listWhereToAddFriend = carddavListForNewFriends != nullptr ? carddavListForNewFriends
						                                                                : ToolModel::getAppFriendList();
						bool created = (listWhereToAddFriend->addFriend(contact) == linphone::FriendList::Status::OK);
						if (created) {
							listWhereToAddFriend->updateSubscriptions();
							if (listWhereToAddFriend->getType() == linphone::FriendList::Type::CardDAV) {
								listWhereToAddFriend->synchronizeFriendsFromServer();
							}
							emit CoreModel::getInstance()->friendCreated(contact);
						}
						mCoreModelConnection->invokeToCore([this, created]() {
							if (created) setSelf(mCoreModelConnection->mCore);
							setIsSaved(created);
							if (created) emit saved();
						});
					});
				});
			}
		});
	}
}

void FriendCore::undo() { // Retrieve values from model
	if (mFriendModel) {
		mFriendModelConnection->invokeToModel([this]() {
			FriendCore *contact = new FriendCore(*this);
			contact->writeFromModel(mFriendModel);
			contact->moveToThread(App::getInstance()->thread());
			mFriendModelConnection->invokeToCore([this, contact]() {
				this->reset(*contact);
				contact->deleteLater();
			});
		});
	}
}

bool FriendCore::isLdap() const {
	return mIsLdap;
}

bool FriendCore::isCardDAV() const {
	return mIsCardDAV;
}

bool FriendCore::isAppFriend() const {
	return mIsAppFriend;
}

bool FriendCore::getReadOnly() const {
	return isLdap() || isCardDAV(); // TODO add conditions for friends retrieved via HTTP
	                                // [misc]vcards-contacts-list=<URL> & CardDAV
}

std::shared_ptr<FriendModel> FriendCore::getFriendModel() {
	return mFriendModel;
}
