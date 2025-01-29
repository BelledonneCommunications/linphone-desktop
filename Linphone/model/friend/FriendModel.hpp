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

#ifndef FRIEND_MODEL_H_
#define FRIEND_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/LinphoneEnums.hpp"

#include <QDateTime>
#include <QObject>
#include <QTimer>
#include <linphone++/linphone.hh>

class FriendModel : public ::Listener<linphone::Friend, linphone::FriendListener>,
                    public linphone::FriendListener,
                    public AbstractObject {
	Q_OBJECT
	friend class FriendCore;

public:
	FriendModel(const std::shared_ptr<linphone::Friend> &contact,
	            const QString &name = QString(),
	            QObject *parent = nullptr);
	~FriendModel();

	QDateTime getPresenceTimestamp() const;
	std::list<std::shared_ptr<linphone::FriendPhoneNumber>> getPhoneNumbers() const;
	std::list<std::shared_ptr<linphone::Address>> getAddresses() const;
	QString getFullName() const;
	QString getName() const;
	QString getGivenName() const;
	QString getFamilyName() const;
	QString getOrganization() const;
	QString getJob() const;
	QString getDefaultAddress() const;
	QString getDefaultFullAddress() const;
	bool getStarred() const;
	std::shared_ptr<linphone::Friend> getFriend() const;
	QString getPictureUri() const;
	QString getVCardAsString() const;
	std::list<std::shared_ptr<linphone::FriendDevice>> getDevices() const;
	linphone::SecurityLevel getSecurityLevel() const;
	linphone::SecurityLevel getSecurityLevelForAddress(const std::shared_ptr<linphone::Address> address) const;

	void setAddress(const std::shared_ptr<linphone::Address> &address);
	void appendPhoneNumber(const std::shared_ptr<linphone::FriendPhoneNumber> &number);
	void appendPhoneNumbers(const std::list<std::shared_ptr<linphone::FriendPhoneNumber>> &numbers);
	void resetPhoneNumbers(const std::list<std::shared_ptr<linphone::FriendPhoneNumber>> &numbers);
	void removePhoneNumber(const QString &number);
	void clearPhoneNumbers();

	void appendAddress(const std::shared_ptr<linphone::Address> &addr);
	void appendAddresses(const std::list<std::shared_ptr<linphone::Address>> &addresses);
	void resetAddresses(const std::list<std::shared_ptr<linphone::Address>> &addresses);
	void removeAddress(const std::shared_ptr<linphone::Address> &addr);
	void clearAddresses();

	void setFullName(const QString &name);
	void setName(const QString &name);
	void setGivenName(const QString &name);
	void setFamilyName(const QString &name);
	void setOrganization(const QString &orga);
	void setJob(const QString &job);

	void setPictureUri(const QString &uri);
	void setStarred(bool starred);

	void remove();

	bool isThisFriend(const std::shared_ptr<linphone::Friend> &data);

	void onUpdated(const std::shared_ptr<linphone::Friend> &data);
	void onRemoved(const std::shared_ptr<linphone::Friend> &data);

	QString mFullName;

signals:
	void pictureUriChanged(const QString &uri);
	void starredChanged(bool starred);
	void addressesChanged();
	void defaultAddressChanged();
	void phoneNumbersChanged();
	// void nameChanged(const QString &name);
	void fullNameChanged(const QString &name);
	void givenNameChanged(const QString &name);
	void familyNameChanged(const QString &name);
	void organizationChanged(const QString &orga);
	void jobChanged(const QString &job);
	void presenceReceived(LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp);
	void updated();
	void removed();

private:
	DECLARE_ABSTRACT_OBJECT

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onPresenceReceived(const std::shared_ptr<linphone::Friend> &contact) override;
};

#endif
