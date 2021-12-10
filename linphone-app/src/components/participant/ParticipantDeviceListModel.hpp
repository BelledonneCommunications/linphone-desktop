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

#ifndef PARTICIPANT_DEVICE_LIST_MODEL_H_
#define PARTICIPANT_DEVICE_LIST_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <QAbstractListModel>

class CallModel;
class ParticipantDeviceModel;

class ParticipantDeviceListModel : public QAbstractListModel {
	Q_OBJECT
	
public:
	ParticipantDeviceListModel (std::shared_ptr<linphone::Participant> participant, QObject *parent = nullptr);
	ParticipantDeviceListModel (CallModel * callModel, QObject *parent = nullptr);
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	int count();
	
	void updateDevices(std::shared_ptr<linphone::Participant> participant);
	
	virtual QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
		
public slots:
	void onSecurityLevelChanged(std::shared_ptr<const linphone::Address> device);

signals:
	void securityLevelChanged(std::shared_ptr<const linphone::Address> device);
	
private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	virtual bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	QList<std::shared_ptr<ParticipantDeviceModel>> mList;
	
};

Q_DECLARE_METATYPE(std::shared_ptr<ParticipantDeviceListModel>)

#endif // PARTICIPANT_MODEL_H_
