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
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QSharedPointer>
#include "app/proxyModel/SortFilterProxyModel.hpp"

class ParticipantDeviceListModel;
class ParticipantDeviceModel;
class ParticipantModel;
class CallModel;

class ParticipantDeviceProxyModel : public SortFilterProxyModel {
	Q_OBJECT
	
public:
	Q_PROPERTY(CallModel * callModel READ getCallModel WRITE setCallModel NOTIFY callModelChanged)
	Q_PROPERTY(bool showMe READ isShowMe WRITE setShowMe NOTIFY showMeChanged)
	Q_PROPERTY(ParticipantDeviceModel * me READ getMe NOTIFY meChanged)
	Q_PROPERTY(ParticipantDeviceModel* activeSpeaker READ getActiveSpeakerModel NOTIFY activeSpeakerChanged)
	
	ParticipantDeviceProxyModel (QObject *parent = nullptr);
	
	Q_INVOKABLE ParticipantDeviceModel* getAt(int row);
	ParticipantDeviceModel* getActiveSpeakerModel();
	ParticipantDeviceModel* getMe() const;
	
	CallModel * getCallModel() const;
	bool isShowMe() const;
	
	
	void setCallModel(CallModel * callModel);	
	void setParticipant(ParticipantModel * participant);
	void setShowMe(const bool& show);
	
	void connectTo(ParticipantDeviceListModel* model);
	
public slots:
	void onCountChanged();
	void onParticipantSpeaking(ParticipantDeviceModel * speakingDevice);
		
signals:
	void activeSpeakerChanged();
	void callModelChanged();
	void showMeChanged();
	void meChanged();
	void participantSpeaking(ParticipantDeviceModel * speakingDevice);
	void conferenceCreated();
	
protected:
	virtual bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	virtual bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
	QSharedPointer<ParticipantDeviceListModel> mDevices;
	CallModel * mCallModel;
	bool mShowMe = true;
};

#endif
