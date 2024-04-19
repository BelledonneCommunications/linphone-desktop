/*
 * Copyright (c) 2024 Belledonne Communications SARL.
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

#include "../proxy/SortFilterProxy.hpp"
#include "core/call/CallGui.hpp"
#include "core/participant/ParticipantDeviceGui.hpp"
#include "tool/AbstractObject.hpp"

class ParticipantDeviceList;
class ParticipantDeviceGui;

class ParticipantDeviceProxy : public SortFilterProxy, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(CallGui *currentCall READ getCurrentCall WRITE setCurrentCall NOTIFY currentCallChanged)
	Q_PROPERTY(ParticipantDeviceGui *me READ getMe NOTIFY meChanged)

public:
	DECLARE_GUI_OBJECT
	ParticipantDeviceProxy(QObject *parent = Q_NULLPTR);
	~ParticipantDeviceProxy();

	CallGui *getCurrentCall() const;
	void setCurrentCall(CallGui *callGui);

	ParticipantDeviceGui *getMe() const;

protected:
	bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;

signals:
	void lUpdate();
	void currentCallChanged();
	void meChanged();

private:
	QString mSearchText;
	CallGui *mCurrentCall = nullptr;
	QSharedPointer<ParticipantDeviceList> mParticipants;
	DECLARE_ABSTRACT_OBJECT
};

#endif
