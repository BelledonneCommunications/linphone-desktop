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
#include "core/proxy/ListProxy.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(FriendCore)

const QString addressLabel = FriendCore::tr("Adresse SIP");
const QString phoneLabel = FriendCore::tr("Téléphone");

QVariant createFriendAddressVariant(const QString &label, const QString &address) {
	QVariantMap map;
	map.insert("label", label);
	map.insert("address", address);
	return map;
}

QVariant createFriendDevice(const QString &name, const QString &address, LinphoneEnums::SecurityLevel level) {
	QVariantMap map;
	map.insert("name", name);
	map.insert("address", address);
	map.insert("securityLevel", QVariant::fromValue(level));
	return map;
}

QSharedPointer<FriendCore> FriendCore::create(const std::shared_ptr<linphone::Friend> &contact) {
	auto sharedPointer = QSharedPointer<FriendCore>(new FriendCore(contact), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

FriendCore::FriendCore(const std::shared_ptr<linphone::Friend> &contact) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	if (contact) {
		mustBeInLinphoneThread(getClassName());
		mFriendModel = Utils::makeQObject_ptr<FriendModel>(contact);
		mFriendModel->setSelf(mFriendModel);
		mConsolidatedPresence = LinphoneEnums::fromLinphone(contact->getConsolidatedPresence());
		mPresenceTimestamp = mFriendModel->getPresenceTimestamp();
		mPictureUri = Utils::coreStringToAppString(contact->getPhoto());
		auto vcard = contact->getVcard();
		if (vcard) {
			mOrganization = Utils::coreStringToAppString(vcard->getOrganization());
			mJob = Utils::coreStringToAppString(vcard->getJobTitle());
			mGivenName = Utils::coreStringToAppString(vcard->getGivenName());
			mFamilyName = Utils::coreStringToAppString(vcard->getFamilyName());
			mFullName = Utils::coreStringToAppString(vcard->getFullName());
			mVCardString = Utils::coreStringToAppString(vcard->asVcard4String());
		}
		auto addresses = contact->getAddresses();
		for (auto &address : addresses) {
			mAddressList.append(
			    createFriendAddressVariant(addressLabel, Utils::coreStringToAppString(address->asStringUriOnly())));
		}
		mDefaultAddress =
		    contact->getAddress() ? Utils::coreStringToAppString(contact->getAddress()->asStringUriOnly()) : QString();
		auto phoneNumbers = contact->getPhoneNumbersWithLabel();
		for (auto &phoneNumber : phoneNumbers) {
			mPhoneNumberList.append(
			    createFriendAddressVariant(Utils::coreStringToAppString(phoneNumber->getLabel()),
			                               Utils::coreStringToAppString(phoneNumber->getPhoneNumber())));
		}

		auto devices = contact->getDevices();
		for (auto &device : devices) {
			mDeviceList.append(createFriendDevice(Utils::coreStringToAppString(device->getDisplayName()),
			                                      // do not use uri only as we want the unique device
			                                      Utils::coreStringToAppString(device->getAddress()->asString()),
			                                      LinphoneEnums::fromLinphone(device->getSecurityLevel())));
		}
		updateVerifiedDevicesCount();

		mStarred = contact->getStarred();
		mIsSaved = true;
	} else {
		mIsSaved = false;
		mStarred = false;
	}

	mIsLdap = false;
	connect(this, &FriendCore::addressChanged, &FriendCore::allAddressesChanged);
	connect(this, &FriendCore::phoneNumberChanged, &FriendCore::allAddressesChanged);
}

FriendCore::FriendCore(const FriendCore &friendCore) {
	// Only copy friend values without models for lambda using and avoid concurrencies.
	mAddressList = friendCore.mAddressList;
	mPhoneNumberList = friendCore.mPhoneNumberList;
	mDefaultAddress = friendCore.mDefaultAddress;
	mGivenName = friendCore.mGivenName;
	mFamilyName = friendCore.mFamilyName;
	mFullName = friendCore.mFullName;
	mOrganization = friendCore.mOrganization;
	mJob = friendCore.mJob;
	mPictureUri = friendCore.mPictureUri;
	mIsSaved = friendCore.mIsSaved;
	mIsLdap = friendCore.mIsLdap;
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
			mFriendModelConnection = QSharedPointer<SafeConnection<FriendCore, FriendModel>>(
			    new SafeConnection<FriendCore, FriendModel>(me, mFriendModel), &QObject::deleteLater);
			mFriendModelConnection->makeConnectToModel(
			    &FriendModel::presenceReceived,
			    [this](LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp) {
				    auto devices = mFriendModel->getDevices();
				    QVariantList devicesList;
				    for (auto &device : devices) {
					    devicesList.append(
					        createFriendDevice(Utils::coreStringToAppString(device->getDisplayName()),
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
			mFriendModelConnection->makeConnectToModel(&FriendModel::jobChanged, [this](const QString &job) {
				mFriendModelConnection->invokeToCore([this, job]() { setJob(job); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::addressesChanged, [this]() {
				auto numbers = mFriendModel->getAddresses();
				QList<QVariant> addr;
				for (auto &num : numbers) {
					addr.append(
					    createFriendAddressVariant(addressLabel, Utils::coreStringToAppString(num->asStringUriOnly())));
				}
				mFriendModelConnection->invokeToCore([this, addr]() { resetPhoneNumbers(addr); });
			});
			mFriendModelConnection->makeConnectToModel(&FriendModel::phoneNumbersChanged, [this]() {
				auto numbers = mFriendModel->getPhoneNumbers();
				QList<QVariant> addr;
				for (auto &num : numbers) {
					addr.append(
					    createFriendAddressVariant(phoneLabel, Utils::coreStringToAppString(num->getPhoneNumber())));
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
				mCoreModelConnection = QSharedPointer<SafeConnection<FriendCore, CoreModel>>(
				    new SafeConnection<FriendCore, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);
			}
			mCoreModelConnection->makeConnectToModel(
			    &CoreModel::callStateChanged,
			    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Call> &call,
			           linphone::Call::State state, const std::string &message) {
				    if (state != linphone::Call::State::End && state != linphone::Call::State::Released) return;
				    auto devices = mFriendModel->getDevices();
				    QVariantList devicesList;
				    for (auto &device : devices) {
					    devicesList.append(
					        createFriendDevice(Utils::coreStringToAppString(device->getDisplayName()),
					                           // do not use uri only as we want the unique device
					                           Utils::coreStringToAppString(device->getAddress()->asString()),
					                           LinphoneEnums::fromLinphone(device->getSecurityLevel())));
				    }
				    mCoreModelConnection->invokeToCore([this, devicesList]() {
					    setDevices(devicesList);
					    updateVerifiedDevicesCount();
				    });
			    });

		} else { // Create
			mCoreModelConnection = QSharedPointer<SafeConnection<FriendCore, CoreModel>>(
			    new SafeConnection<FriendCore, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);
		}
	}
}

void FriendCore::reset(const FriendCore &contact) {
	resetAddresses(contact.getAddresses());
	resetPhoneNumbers(contact.getPhoneNumbers());
	setDefaultAddress(contact.getDefaultAddress());
	setGivenName(contact.getGivenName());
	setFamilyName(contact.getFamilyName());
	setOrganization(contact.getOrganization());
	setJob(contact.getJob());
	setPictureUri(contact.getPictureUri());
	setIsSaved(mFriendModel != nullptr);
}

QString FriendCore::getDisplayName() const {
	return !mFullName.isEmpty() ? mFullName : mGivenName + " " + mFamilyName;
}

QString FriendCore::getGivenName() const {
	return mGivenName;
}

void FriendCore::setGivenName(const QString &name) {
	if (mGivenName != name) {
		mGivenName = name;
		emit givenNameChanged(name);
		emit displayNameChanged();
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
		mFamilyName = name;
		emit familyNameChanged(name);
		emit displayNameChanged();
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
		mPhoneNumberList.replace(index, createFriendAddressVariant(label.isEmpty() ? oldLabel : label, phoneNumber));
		emit phoneNumberChanged();
		setIsSaved(false);
	}
}

void FriendCore::removePhoneNumber(int index) {
	if (index != -1) mPhoneNumberList.remove(index);
	emit phoneNumberChanged();
}

void FriendCore::appendPhoneNumber(const QString &label, const QString &number) {
	mPhoneNumberList.append(createFriendAddressVariant(label, number));
	emit phoneNumberChanged();
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

void FriendCore::setAddressAt(int index, const QString &label, QString address) {
	if (index < 0 || index >= mAddressList.count()) return;
	auto map = mAddressList[index].toMap();
	if (Utils::isUsername(address)) {
		address = Utils::interpretUrl(address);
	}
	auto oldLabel = map["label"].toString();
	if (/*oldLabel != label || */ map["address"] != address) {
		mAddressList.replace(index, createFriendAddressVariant(label.isEmpty() ? oldLabel : label, address));
		emit addressChanged();
		setIsSaved(false);
	}
}

void FriendCore::removeAddress(int index) {
	if (index < 0 && index >= mAddressList.size()) return;
	auto map = mAddressList[index].toMap();
	if (map["address"].toString() == mDefaultAddress) mDefaultAddress.clear();
	mAddressList.remove(index);
	emit addressChanged();
}

void FriendCore::appendAddress(const QString &addr) {
	if (addr.isEmpty()) return;
	QString interpretedAddress = Utils::interpretUrl(addr);
	auto linAddr = linphone::Factory::get()->createAddress(Utils::appStringToCoreString(interpretedAddress));
	if (!linAddr) Utils::showInformationPopup(tr("Erreur"), tr("Adresse invalide"), false);
	else {
		mAddressList.append(createFriendAddressVariant(addressLabel, interpretedAddress));
		if (mDefaultAddress.isEmpty()) mDefaultAddress = interpretedAddress;
		emit addressChanged();
	}
}

void FriendCore::resetAddresses(QList<QVariant> newList) {
	mAddressList = newList;
	emit addressChanged();
}

QList<QVariant> FriendCore::getAllAddresses() const {
	return mAddressList + mPhoneNumberList;
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

QString FriendCore::getDefaultAddress() const {
	return mDefaultAddress;
}

void FriendCore::setDefaultAddress(const QString &address) {
	auto it = std::find_if(mAddressList.begin(), mAddressList.end(),
	                       [address](const QVariant &a) { return a.toMap()["address"].toString() == address; });
	if (it == mAddressList.end()) appendAddress(address);
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
		emit isSavedChanged(mIsSaved);
	}
}

void FriendCore::writeIntoModel(std::shared_ptr<FriendModel> model) const {
	mustBeInLinphoneThread(QString("[") + gClassName + "] " + Q_FUNC_INFO);
	model->getFriend()->edit();
	// needed to create the vcard if not created yet
	model->setName(!mFullName.isEmpty()
	                   ? mFullName
	                   : mGivenName + (mFamilyName.isEmpty() || mGivenName.isEmpty() ? "" : " ") + mFamilyName);
	auto core = CoreModel::getInstance()->getCore();

	std::list<std::shared_ptr<linphone::Address>> addresses;
	for (auto &addr : mAddressList) {
		auto friendAddress = addr.toMap();
		auto address =
		    linphone::Factory::get()->createAddress(Utils::appStringToCoreString(friendAddress["address"].toString()));
		addresses.push_back(address);
	}
	model->resetAddresses(addresses);

	model->setAddress(ToolModel::interpretUrl(mDefaultAddress));

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
	model->setJob(mJob);
	model->setPictureUri(mPictureUri);
	model->getFriend()->done();
}

void FriendCore::writeFromModel(const std::shared_ptr<FriendModel> &model) {
	mustBeInLinphoneThread(QString("[") + gClassName + "] " + Q_FUNC_INFO);

	QList<QVariant> addresses;
	for (auto &addr : model->getAddresses()) {
		addresses.append(
		    createFriendAddressVariant(addressLabel, Utils::coreStringToAppString(addr->asStringUriOnly())));
	}
	mAddressList = addresses;

	QList<QVariant> phones;
	for (auto &number : model->getPhoneNumbers()) {
		phones.append(createFriendAddressVariant(Utils::coreStringToAppString(number->getLabel()),
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
		mFriendModelConnection->invokeToModel([this]() {
			auto contact = mFriendModel->getFriend();
			// emit CoreModel::getInstance()->friendRemoved(contact);
			contact->remove();
			mFriendModelConnection->invokeToCore([this]() { removed(this); });
		});
	}
}

void FriendCore::save() { // Save Values to model
	mustBeInMainThread(getClassName() + "::save()");
	if (mAddressList.size() > 0) {
		auto it = std::find_if(mAddressList.begin(), mAddressList.end(), [this](const QVariant &a) {
			return a.toMap()["address"].toString() == mDefaultAddress;
		});
		if (it == mAddressList.end()) {
			mDefaultAddress = mAddressList[0].toMap()["address"].toString();
			emit defaultAddressChanged();
		}
	} else {
		mDefaultAddress = "";
		emit defaultAddressChanged();
	}
	FriendCore *thisCopy = new FriendCore(*this); // Pointer to avoid multiple copies in lambdas
	if (mFriendModel) {
		mFriendModelConnection->invokeToModel([this, thisCopy]() { // Copy values to avoid concurrency
			mustBeInLinphoneThread(getClassName() + "::save()");
			thisCopy->writeIntoModel(mFriendModel);
			thisCopy->deleteLater();
			mVCardString = mFriendModel->getVCardAsString();
			mFriendModelConnection->invokeToCore([this]() { saved(); });
			setIsSaved(true);
		});
	} else {
		mCoreModelConnection->invokeToModel([this, thisCopy]() {
			std::shared_ptr<linphone::Friend> contact;
			auto core = CoreModel::getInstance()->getCore();
			for (auto &addr : mAddressList) {
				auto friendAddress = addr.toMap();
				auto linphoneAddr = ToolModel::interpretUrl(friendAddress["address"].toString());
				contact = core->findFriend(linphoneAddr);
				if (contact) break;
			}
			if (contact != nullptr) {
				auto friendModel = Utils::makeQObject_ptr<FriendModel>(contact);
				friendModel->setSelf(friendModel);
				mCoreModelConnection->invokeToCore([this, thisCopy, friendModel] {
					mFriendModel = friendModel;
					mCoreModelConnection->invokeToModel([this, thisCopy] {
						thisCopy->writeIntoModel(mFriendModel);
						thisCopy->deleteLater();
						mVCardString = mFriendModel->getVCardAsString();
					});
					saved();
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
						auto carddavListForNewFriends = SettingsModel::getCarddavListForNewFriends();
						auto listWhereToAddFriend = carddavListForNewFriends != nullptr ? carddavListForNewFriends
						                                                                : core->getDefaultFriendList();
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

bool FriendCore::getIsLdap() const {
	return mIsLdap;
}
void FriendCore::setIsLdap(bool data) {
	if (mIsLdap != data) {
		mIsLdap = data;
		emit readOnlyChanged();
	}
}

bool FriendCore::getReadOnly() const {
	return getIsLdap(); // TODO add conditions for friends retrieved via HTTP [misc]vcards-contacts-list=<URL> & CardDAV
}
