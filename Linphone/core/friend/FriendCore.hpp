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

#ifndef FRIEND_CORE_H_
#define FRIEND_CORE_H_

// #include "FriendAddressList.hpp"
#include "core/variant/VariantList.hpp"
#include "model/friend/FriendModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include "tool/thread/SafeSharedPointer.hpp"
#include <linphone++/linphone.hh>

#include <QDateTime>
#include <QMap>
#include <QObject>
#include <QSharedPointer>

// This object is defferent from usual Core. It set internal data from directly from GUI.
// Values are saved on request.
// This allow revert feature.

class CoreModel;
class FriendCore;

struct FriendDevice {
	QString name;
	QString address;
	LinphoneEnums::SecurityLevel securityLevel;
};

class FriendCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QList<QVariant> allAddresses READ getAllAddresses NOTIFY allAddressesChanged)
	Q_PROPERTY(QList<QVariant> phoneNumbers READ getPhoneNumbers NOTIFY phoneNumberChanged)
	Q_PROPERTY(QList<QVariant> addresses READ getAddresses NOTIFY addressChanged)
	Q_PROPERTY(QList<QVariant> devices READ getDevices NOTIFY devicesChanged)
	Q_PROPERTY(int verifiedDeviceCount MEMBER mVerifiedDeviceCount NOTIFY verifiedDevicesChanged)
	Q_PROPERTY(QString givenName READ getGivenName WRITE setGivenName NOTIFY givenNameChanged)
	Q_PROPERTY(QString familyName READ getFamilyName WRITE setFamilyName NOTIFY familyNameChanged)
	Q_PROPERTY(QString fullName READ getFullName NOTIFY fullNameChanged)
	Q_PROPERTY(QString organization READ getOrganization WRITE setOrganization NOTIFY organizationChanged)
	Q_PROPERTY(QString job READ getJob WRITE setJob NOTIFY jobChanged)
	Q_PROPERTY(QString defaultAddress READ getDefaultAddress WRITE setDefaultAddress NOTIFY defaultAddressChanged)
	Q_PROPERTY(QString defaultFullAddress READ getDefaultFullAddress WRITE setDefaultFullAddress NOTIFY
	               defaultFullAddressChanged)
	Q_PROPERTY(QDateTime presenceTimestamp READ getPresenceTimestamp NOTIFY presenceTimestampChanged)
	Q_PROPERTY(LinphoneEnums::ConsolidatedPresence consolidatedPresence READ getConsolidatedPresence NOTIFY
	               consolidatedPresenceChanged)
	Q_PROPERTY(bool isSaved READ getIsSaved NOTIFY isSavedChanged)
	Q_PROPERTY(bool isStored READ getIsStored NOTIFY isStoredChanged)
	Q_PROPERTY(QString pictureUri READ getPictureUri WRITE setPictureUri NOTIFY pictureUriChanged)
	Q_PROPERTY(bool starred READ getStarred WRITE lSetStarred NOTIFY starredChanged)
	Q_PROPERTY(bool readOnly READ getReadOnly CONSTANT)
	Q_PROPERTY(bool isLdap READ isLdap CONSTANT)
	Q_PROPERTY(bool isAppFriend READ isAppFriend CONSTANT)
	Q_PROPERTY(bool isCardDAV READ isCardDAV CONSTANT)

public:
	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<FriendCore>
	create(const std::shared_ptr<linphone::Friend> &contact, bool isStored = true, int sourceFlags = 0);
	FriendCore(const std::shared_ptr<linphone::Friend> &contact, bool isStored = true, int sourceFlags = 0);
	FriendCore(const FriendCore &friendCore);
	~FriendCore();
	void setSelf(QSharedPointer<FriendCore> me);
	void setSelf(SafeSharedPointer<FriendCore> me);
	void reset(const FriendCore &contact);

	QString getFullName() const;
	void setFullName(const QString &name);

	QString getFamilyName() const;
	void setFamilyName(const QString &name);

	QString getGivenName() const;
	void setGivenName(const QString &name);

	QString getOrganization() const;
	void setOrganization(const QString &name);

	QString getJob() const;
	void setJob(const QString &name);

	bool getStarred() const;
	void onStarredChanged(bool starred);

	Q_INVOKABLE QString getVCard() const;

	QList<QVariant> getPhoneNumbers() const;
	QVariant getPhoneNumberAt(int index) const;
	Q_INVOKABLE void appendPhoneNumber(const QString &label, const QString &number);
	Q_INVOKABLE void removePhoneNumber(int index);
	Q_INVOKABLE void setPhoneNumberAt(int index, const QString &label, const QString &phoneNumber);

	QList<QVariant> getAddresses() const;
	QVariant getAddressAt(int index) const;
	Q_INVOKABLE void appendAddress(const QString &addr);
	Q_INVOKABLE void removeAddress(int index);
	Q_INVOKABLE void setAddressAt(int index, QString label, QString address);

	void setDefaultAddress(const QString &address);
	QString getDefaultAddress() const;
	void setDefaultFullAddress(const QString &address);
	QString getDefaultFullAddress() const;

	QList<QVariant> getAllAddresses() const;

	QList<QVariant> getDevices() const;
	void updateVerifiedDevicesCount();
	void setDevices(QVariantList devices);
	Q_INVOKABLE LinphoneEnums::SecurityLevel getSecurityLevelForAddress(const QString &address) const;

	LinphoneEnums::ConsolidatedPresence getConsolidatedPresence() const;
	void setConsolidatedPresence(LinphoneEnums::ConsolidatedPresence presence);

	QDateTime getPresenceTimestamp() const;
	void setPresenceTimestamp(QDateTime presenceTimestamp);

	bool getIsSaved() const;
	void setIsSaved(bool isSaved);

	bool getIsStored() const; // Exist in DB
	void setIsStored(bool isStored);

	QString getPictureUri() const;
	void setPictureUri(const QString &uri);
	void onPictureUriChanged(QString uri);

	void onPresenceReceived(LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp);

	bool isLdap() const;
	bool isAppFriend() const;
	bool isCardDAV() const;
	bool getReadOnly() const;

	std::shared_ptr<FriendModel> getFriendModel();

	Q_INVOKABLE void remove();
	Q_INVOKABLE void save();
	Q_INVOKABLE void undo();

protected:
	void resetPhoneNumbers(QList<QVariant> newList);
	void resetAddresses(QList<QVariant> newList);

signals:
	void friendUpdated();
	void givenNameChanged(QString name);
	void familyNameChanged(QString name);
	void fullNameChanged(QString name);
	void starredChanged();
	void phoneNumberChanged();
	void addressChanged();
	void organizationChanged();
	void jobChanged();
	void consolidatedPresenceChanged(LinphoneEnums::ConsolidatedPresence level);
	void presenceTimestampChanged(QDateTime presenceTimestamp);
	void pictureUriChanged();
	void saved();
	void isSavedChanged(bool isSaved);
	void isStoredChanged();
	void removed(FriendCore *contact);
	void defaultAddressChanged();
	void defaultFullAddressChanged();
	void allAddressesChanged();
	void devicesChanged();
	void verifiedDevicesChanged();
	void lSetStarred(bool starred);

protected:
	void writeIntoModel(std::shared_ptr<FriendModel> model) const;
	void writeFromModel(const std::shared_ptr<FriendModel> &model);

	LinphoneEnums::ConsolidatedPresence mConsolidatedPresence = LinphoneEnums::ConsolidatedPresence::Offline;
	QDateTime mPresenceTimestamp;
	QString mGivenName;
	QString mFamilyName;
	QString mFullName;
	QString mOrganization;
	QString mJob;
	bool mStarred;
	QList<QVariant> mPhoneNumberList;
	QList<QVariant> mAddressList;
	QList<QVariant> mDeviceList;
	int mVerifiedDeviceCount;
	QString mDefaultAddress; // Uri only
	QString mDefaultFullAddress;
	QString mPictureUri;
	bool mIsSaved;
	bool mIsStored;
	QString mVCardString;
	bool mIsLdap, mIsCardDAV, mIsAppFriend;
	std::shared_ptr<FriendModel> mFriendModel;
	QSharedPointer<SafeConnection<FriendCore, FriendModel>> mFriendModelConnection;
	QSharedPointer<SafeConnection<FriendCore, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};

Q_DECLARE_METATYPE(FriendCore *)
#endif
