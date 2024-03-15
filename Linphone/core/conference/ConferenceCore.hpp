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

#ifndef CONFERENCE_CORE_H_
#define CONFERENCE_CORE_H_

#include "model/conference/ConferenceModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class ConferenceCore : public QObject, public AbstractObject {
	Q_OBJECT
public:
	Q_PROPERTY(QString subject READ getSubject NOTIFY subjectChanged)
	Q_PROPERTY(QDateTime startDate READ getStartDate CONSTANT)
	// Q_PROPERTY(ParticipantListModel* participants READ getParticipantListModel CONSTANT)
	// Q_PROPERTY(ParticipantModel* localParticipant READ getLocalParticipant NOTIFY localParticipantChanged)
	Q_PROPERTY(bool isReady MEMBER mIsReady WRITE setIsReady NOTIFY isReadyChanged)
	Q_PROPERTY(int participantDeviceCount READ getParticipantDeviceCount NOTIFY participantDeviceCountChanged)

	// Should be call from model Thread. Will be automatically in App thread after initialization
	static QSharedPointer<ConferenceCore> create(const std::shared_ptr<linphone::Conference> &conference);
	ConferenceCore(const std::shared_ptr<linphone::Conference> &conference);
	~ConferenceCore();
	void setSelf(QSharedPointer<ConferenceCore> me);

	bool updateLocalParticipant(); // true if changed

	QString getSubject() const;
	QDateTime getStartDate() const;
	Q_INVOKABLE qint64 getElapsedSeconds() const;
	// Q_INVOKABLE ParticipantModel *getLocalParticipant() const;
	// ParticipantListModel *getParticipantListModel() const;
	// std::list<std::shared_ptr<linphone::Participant>>
	// getParticipantList() const; // SDK exclude me. We want to get ALL participants.
	int getParticipantDeviceCount() const;

	void setIsReady(bool state);

	//---------------------------------------------------------------------------

signals:
	void subjectChanged();
	void isReadyChanged();
	void participantDeviceCountChanged();

private:
	QSharedPointer<SafeConnection<ConferenceCore, ConferenceModel>> mConferenceModelConnection;
	std::shared_ptr<ConferenceModel> mConferenceModel;

	bool mIsReady = false;
	QString mSubject;
	QDateTime mStartDate = QDateTime::currentDateTime();

	DECLARE_ABSTRACT_OBJECT
};

Q_DECLARE_METATYPE(ConferenceCore *)
#endif
