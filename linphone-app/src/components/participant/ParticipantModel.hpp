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

#ifndef PARTICIPANT_MODEL_H_
#define PARTICIPANT_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

class ContactModel;
class ParticipantDeviceProxyModel;
class ParticipantDeviceListModel;

class ParticipantModel : public QObject {
    Q_OBJECT

public:
    ParticipantModel (std::shared_ptr<linphone::Participant> linphoneParticipant, QObject *parent = nullptr);
	
	Q_PROPERTY(ContactModel *contactModel READ getContactModel CONSTANT)
	Q_PROPERTY(QString sipAddress MEMBER mSipAddress READ getSipAddress WRITE setSipAddress NOTIFY sipAddressChanged)
	Q_PROPERTY(bool adminStatus MEMBER mAdminStatus READ getAdminStatus WRITE setAdminStatus NOTIFY adminStatusChanged)
    Q_PROPERTY(QDateTime creationTime READ getCreationTime CONSTANT)
    Q_PROPERTY(bool focus READ isFocus CONSTANT)
	Q_PROPERTY(int securityLevel READ getSecurityLevel NOTIFY securityLevelChanged)
	Q_PROPERTY(int deviceCount READ getDeviceCount NOTIFY deviceCountChanged)
	
	Q_PROPERTY(bool inviting READ getInviting NOTIFY invitingChanged)
  
	ContactModel *getContactModel() const;
    QString getSipAddress() const;
    QDateTime getCreationTime() const;
    //std::list<std::shared_ptr<linphone::ParticipantDevice>> getDevices() const;
    bool getAdminStatus() const;
    bool isFocus() const;
	int getSecurityLevel() const;
	int getDeviceCount();
	bool getInviting() const;
	
	bool isMe() const;
	
	void setSipAddress(const QString& address);
	void setAdminStatus(const bool& status);
	void setParticipant(std::shared_ptr<linphone::Participant> participant);
	
	std::shared_ptr<linphone::Participant>  getParticipant();
	Q_INVOKABLE ParticipantDeviceProxyModel * getProxyDevices();
	std::shared_ptr<ParticipantDeviceListModel> getParticipantDevices();
    //linphone::ChatRoomSecurityLevel getSecurityLevel() const;
    //std::shared_ptr<linphone::ParticipantDevice> findDevice(const std::shared_ptr<const linphone::Address> & address) const;
	
	void startInvitation(const int& secondes = 30);	// Start a timer to remove the model if the invitation didn't ended after some time
	
	
public slots:
	void onSecurityLevelChanged();	
	void onDeviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void onEndOfInvitation();
	
signals:
	void securityLevelChanged();
	void deviceSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);
	void sipAddressChanged();
	void updateAdminStatus(const std::shared_ptr<linphone::Participant> participant, const bool& isAdmin);// Split in two signals in order to sequancialize execution between SDK and GUI
	void adminStatusChanged();
	void deviceCountChanged();
	void invitingChanged();
	
	void invitationTimeout(ParticipantModel* model);
	
//    void contactUpdated ();


private:

    std::shared_ptr<linphone::Participant> mParticipant;
	std::shared_ptr<ParticipantDeviceListModel> mParticipantDevices;
	
// Variables when Linphone Participant has not been created
	QString mSipAddress;
	bool mAdminStatus;
};

//Q_DECLARE_METATYPE(ParticipantModel *);
Q_DECLARE_METATYPE(std::shared_ptr<ParticipantModel>);

#endif // PARTICIPANT_MODEL_H_
