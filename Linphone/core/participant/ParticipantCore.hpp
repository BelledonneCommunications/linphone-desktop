/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef PARTICIPANT_CORE_H_
#define PARTICIPANT_CORE_H_

#include "tool/thread/SafeConnection.hpp"
#include <linphone++/linphone.hh>

#include <QDateTime>
#include <QMap>
#include <QObject>
#include <QSharedPointer>
#include <QString>

class FriendCore;
class ParticipantDeviceProxy;
class ParticipantDeviceList;
class ParticipantModel;

class ParticipantCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString sipAddress READ getSipAddress WRITE setSipAddress NOTIFY sipAddressChanged)
	Q_PROPERTY(QString displayName READ getDisplayName WRITE setDisplayName NOTIFY displayNameChanged)
	Q_PROPERTY(bool isAdmin READ isAdmin WRITE setIsAdmin NOTIFY isAdminChanged)
	Q_PROPERTY(bool isMe READ isMe NOTIFY isMeChanged)
	Q_PROPERTY(QDateTime creationTime READ getCreationTime CONSTANT)
	Q_PROPERTY(bool focus READ isFocus CONSTANT)
	Q_PROPERTY(int securityLevel READ getSecurityLevel NOTIFY securityLevelChanged)
	Q_PROPERTY(int deviceCount READ getDeviceCount NOTIFY deviceCountChanged)
	Q_PROPERTY(QList<QVariant> devices READ getParticipantDevices NOTIFY deviceChanged)

public:
	static QSharedPointer<ParticipantCore> create(const std::shared_ptr<linphone::Participant> &participant);
	ParticipantCore(const std::shared_ptr<linphone::Participant> &participant);
	~ParticipantCore();

	void setSelf(QSharedPointer<ParticipantCore> me);

	QString getDisplayName() const;
	QString getSipAddress() const;
	QDateTime getCreationTime() const;
	bool isAdmin() const;
	bool isFocus() const;
	int getSecurityLevel() const;
	int getDeviceCount() const;

	bool isMe() const;
	void setIsMe(bool isMe);
	void updateIsMe();

	void setSipAddress(const QString &address);
	void setDisplayName(const QString &name);
	void setCreationTime(const QDateTime &date);
	void setIsAdmin(const bool &status);
	void setIsFocus(const bool &focus);
	void setSecurityLevel(int level);

	QList<QVariant> getParticipantDevices();

public slots:
	void onSecurityLevelChanged();
	void onDeviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void onEndOfInvitation();

signals:
	void securityLevelChanged();
	void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void sipAddressChanged();
	void isAdminChanged();
	void isFocusChanged();
	void isMeChanged();
	void deviceCountChanged();
	void invitingChanged();
	void creationTimeChanged();
	void displayNameChanged();

	void lStartInvitation(const int &secs = 30);
	void lSetIsAdmin(bool status);

	void invitationTimeout(ParticipantCore *model);

	void deviceChanged();

private:
	std::shared_ptr<ParticipantModel> mParticipantModel;
	QSharedPointer<SafeConnection<ParticipantCore, ParticipantModel>> mParticipantConnection;

	QList<QVariant> mParticipantDevices;

	QString mDisplayName;
	QString mSipAddress;
	QDateTime mCreationTime;
	bool mAdminStatus;
	bool mIsFocus;
	int mSecurityLevel;
	bool mIsMe;

	DECLARE_ABSTRACT_OBJECT
};

Q_DECLARE_METATYPE(QSharedPointer<ParticipantCore>);

#endif // PARTICIPANT_CORE_H_
