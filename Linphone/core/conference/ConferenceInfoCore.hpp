/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#ifndef CONFERENCE_INFO_CORE_H_
#define CONFERENCE_INFO_CORE_H_

#include "core/timezone/TimeZone.hpp"
#include "model/conference/ConferenceInfoModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <linphone++/linphone.hh>

#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <QTimeZone>
#include <QTimer>

class ParticipantListModel;
// class TimeZoneModel;

class ConferenceInfoCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	Q_PROPERTY(TimeZoneModel *timeZoneModel READ getTimeZoneModel WRITE setTimeZoneModel NOTIFY timeZoneModelChanged)
	Q_PROPERTY(QDateTime dateTime READ getDateTimeSystem WRITE setDateTime NOTIFY dateTimeChanged)
	Q_PROPERTY(QDateTime endDateTime READ getEndDateTime WRITE setEndDateTime NOTIFY endDateTimeChanged)
	Q_PROPERTY(QDateTime dateTimeUtc READ getDateTimeUtc NOTIFY dateTimeChanged)
	Q_PROPERTY(QString startEndDateString READ getStartEndDateString NOTIFY dateTimeChanged)
	Q_PROPERTY(int duration READ getDuration WRITE setDuration NOTIFY durationChanged)
	Q_PROPERTY(
	    QString organizerAddress READ getOrganizerAddress WRITE setOrganizerAddress NOTIFY organizerAddressChanged)
	Q_PROPERTY(QString organizerName READ getOrganizerName WRITE setOrganizerName NOTIFY organizerNameChanged)
	Q_PROPERTY(QString subject READ getSubject WRITE setSubject NOTIFY subjectChanged)
	Q_PROPERTY(QString description READ getDescription WRITE setDescription NOTIFY descriptionChanged)
	Q_PROPERTY(QString uri READ getUri NOTIFY uriChanged)

	Q_PROPERTY(bool haveModel READ getHaveModel NOTIFY haveModelChanged)
	Q_PROPERTY(bool isScheduled READ isScheduled WRITE setIsScheduled NOTIFY isScheduledChanged)
	Q_PROPERTY(bool isEnded READ isEnded WRITE setIsEnded NOTIFY isEndedChanged)
	Q_PROPERTY(bool inviteEnabled READ inviteEnabled WRITE enableInvite NOTIFY inviteEnabledChanged)
	Q_PROPERTY(int participantCount READ getParticipantCount NOTIFY participantsChanged)

	Q_PROPERTY(QVariantList participants READ getParticipants NOTIFY participantsChanged)
	Q_PROPERTY(LinphoneEnums::ConferenceInfoState state READ getConferenceInfoState NOTIFY conferenceInfoStateChanged)
	Q_PROPERTY(LinphoneEnums::ConferenceSchedulerState schedulerState READ getConferenceSchedulerState NOTIFY
	               conferenceSchedulerStateChanged)

	static QSharedPointer<ConferenceInfoCore> create(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo);
	ConferenceInfoCore(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo, QObject *parent = nullptr);
	ConferenceInfoCore(const ConferenceInfoCore &conferenceInfoCore);
	~ConferenceInfoCore();
	void reset(const ConferenceInfoCore &contact);

	void setSelf(SafeSharedPointer<ConferenceInfoCore> me);
	void setSelf(QSharedPointer<ConferenceInfoCore> me);

	QDateTime getDateTimeUtc() const;
	QDateTime getDateTimeSystem() const;
	int getDuration() const;
	QDateTime getEndDateTime() const;
	QDateTime getEndDateTimeUtc() const;
	QString getOrganizerName() const;
	QString getOrganizerAddress() const;
	QString getSubject() const;
	QString getDescription() const;
	QString getUri() const;
	bool getHaveModel() const;
	void setHaveModel(const bool &haveModel);
	bool isScheduled() const;
	void setIsScheduled(const bool &on);
	bool computeIsEnded() const;
	bool isEnded() const;
	void setIsEnded(bool ended);
	bool inviteEnabled() const;
	QVariantList getParticipants() const;
	int getParticipantCount() const;
	TimeZoneModel *getTimeZoneModel() const;
	// QString getIcalendarString() const;
	LinphoneEnums::ConferenceInfoState getConferenceInfoState() const;
	LinphoneEnums::ConferenceSchedulerState getConferenceSchedulerState() const;
	QString toStartEndDateString();

	void setDateTime(const QDateTime &date);
	void setEndDateTime(const QDateTime &date);
	void setDuration(int duration);
	void setSubject(const QString &subject);
	void setOrganizerName(const QString &organizer);
	void setOrganizerAddress(const QString &organizer);
	void setUri(const QString &uri);
	void setTimeZoneModel(TimeZoneModel *model);
	void setDescription(const QString &description);
	void enableInvite(const bool &enable);
	void setConferenceInfoState(LinphoneEnums::ConferenceInfoState state);
	void setConferenceSchedulerState(LinphoneEnums::ConferenceSchedulerState state);

	Q_INVOKABLE void addParticipant(const QString &address);
	Q_INVOKABLE void addParticipants(const QStringList &addresses);
	Q_INVOKABLE void removeParticipant(const QString &address);
	Q_INVOKABLE void removeParticipant(const int &index);
	Q_INVOKABLE QString getParticipantAddressAt(const int &index);
	Q_INVOKABLE void clearParticipants();
	void resetParticipants(QVariantList participants);
	Q_INVOKABLE void resetParticipants(const QStringList &adresses);
	Q_INVOKABLE int getParticipantIndex(const QString &address);
	Q_INVOKABLE QString getStartEndDateString();

	void writeFromModel(const std::shared_ptr<ConferenceInfoModel> &model);
	void writeIntoModel(std::shared_ptr<ConferenceInfoModel> model);

	Q_INVOKABLE void save();
	Q_INVOKABLE void undo();
	Q_INVOKABLE void cancelCreation();

	virtual void onInvitationsSent(const std::list<std::shared_ptr<linphone::Address>> &failedInvitations);

	Q_INVOKABLE bool isAllDayConf() const;

signals:
	void dateTimeChanged();
	void endDateTimeChanged();
	void durationChanged();
	void organizerAddressChanged();
	void organizerNameChanged();
	void subjectChanged();
	void descriptionChanged();
	void participantsChanged();
	void uriChanged();
	void haveModelChanged();
	void isScheduledChanged();
	void isEndedChanged();
	void inviteEnabledChanged();
	void conferenceInfoStateChanged();
	void conferenceSchedulerStateChanged();
	void timeZoneModelChanged();
	void saveFailed();

	void dataSaved();

	void invitationsSent();
	void removed(ConferenceInfoCore *confInfo);

	void lCancelConferenceInfo();
	void lDeleteConferenceInfo(); // Remove completly this conference info from DB

private:
	std::shared_ptr<ConferenceInfoModel> mConferenceInfoModel = nullptr;
	QSharedPointer<SafeConnection<ConferenceInfoCore, ConferenceInfoModel>> mConfInfoModelConnection;
	QSharedPointer<SafeConnection<ConferenceInfoCore, ConferenceSchedulerModel>> mConfSchedulerModelConnection;
	QSharedPointer<SafeConnection<ConferenceInfoCore, CoreModel>> mCoreModelConnection;

	QDateTime mDateTime;
	QDateTime mEndDateTime;
	int mDuration;
	QString mOrganizerAddress;
	QString mOrganizerName;
	QString mSubject;
	QString mDescription;
	QString mUri;
	QVariantList mParticipants;
	QSharedPointer<TimeZoneModel> mTimeZoneModel;
	LinphoneEnums::ConferenceSchedulerState mConferenceSchedulerState;
	LinphoneEnums::ConferenceInfoState mConferenceInfoState = LinphoneEnums::ConferenceInfoState::New;
	bool mHaveModel = false;
	bool mIsScheduled;
	bool mIsEnded = false;
	bool mInviteEnabled = true;
	DECLARE_ABSTRACT_OBJECT
};

Q_DECLARE_METATYPE(ConferenceInfoCore *)

#endif
