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

#ifndef PARTICIPANT_DEVICE_PROXY_MODEL_H_
#define PARTICIPANT_DEVICE_PROXY_MODEL_H_

#include <linphone++/linphone.hh>
// =============================================================================
#include "../proxy/SortFilterProxy.hpp"
#include <QDateTime>
#include <QObject>
#include <QSharedPointer>
#include <QString>

class ParticipantDeviceList;
class ParticipantDeviceCore;
class ParticipantCore;
class CallModel;

class ParticipantDeviceProxy : public SortFilterProxy {
	Q_OBJECT

public:
	Q_PROPERTY(CallModel *callModel READ getCallModel WRITE setCallModel NOTIFY callModelChanged)
	Q_PROPERTY(bool showMe READ isShowMe WRITE setShowMe NOTIFY showMeChanged)
	Q_PROPERTY(ParticipantDeviceCore *me READ getMe NOTIFY meChanged)
	Q_PROPERTY(ParticipantDeviceCore *activeSpeaker READ getActiveSpeakerModel NOTIFY activeSpeakerChanged)

	ParticipantDeviceProxy(QObject *parent = nullptr);
	~ParticipantDeviceProxy();

	Q_INVOKABLE ParticipantDeviceCore *getAt(int row);
	ParticipantDeviceCore *getActiveSpeakerModel();
	ParticipantDeviceCore *getMe() const;

	CallModel *getCallModel() const;
	bool isShowMe() const;

	void setCallModel(CallModel *callModel);
	// void setParticipant(ParticipantCore *participantCore);
	void setShowMe(const bool &show);

	void connectTo(ParticipantDeviceList *model);

public slots:
	void onCountChanged();
	void onParticipantSpeaking(ParticipantDeviceCore *speakingDevice);

signals:
	void activeSpeakerChanged();
	void callModelChanged();
	void showMeChanged();
	void meChanged();
	void participantSpeaking(ParticipantDeviceCore *speakingDevice);
	void conferenceCreated();

protected:
	virtual bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

	CallModel *mCallModel;
	bool mShowMe = true;

	QSharedPointer<ParticipantDeviceList> mList;
};

#endif
