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

class ParticipantModel : public QObject {

    Q_OBJECT;

    Q_PROPERTY(QString address READ getAddress CONSTANT);
    Q_PROPERTY(QDateTime creationTime READ getCreationTime CONSTANT);
    Q_PROPERTY(bool admin READ isAdmin CONSTANT);
    Q_PROPERTY(bool focus READ isFocus CONSTANT);

public:
    ParticipantModel (std::shared_ptr<linphone::Participant> linphoneParticipant, QObject *parent = nullptr);
  
    QString getAddress() const;
    QDateTime getCreationTime() const;
    //std::list<std::shared_ptr<linphone::ParticipantDevice>> getDevices() const;
    bool isAdmin() const;
    bool isFocus() const;
    //linphone::ChatRoomSecurityLevel getSecurityLevel() const;
    //std::shared_ptr<linphone::ParticipantDevice> findDevice(const std::shared_ptr<const linphone::Address> & address) const;

//signals:
//    void contactUpdated ();


private:

    std::shared_ptr<linphone::Participant> mLinphoneParticipant;
};

Q_DECLARE_METATYPE(ParticipantModel *);

#endif // PARTICIPANT_MODEL_H_
