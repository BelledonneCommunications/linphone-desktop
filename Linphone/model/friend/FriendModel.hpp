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
public:
	FriendModel(const std::shared_ptr<linphone::Friend> &contact, QObject *parent = nullptr);
	~FriendModel();

	QDateTime getPresenceTimestamp() const;
	std::shared_ptr<linphone::Friend> getFriend() const;

	void setPictureUri(QString uri);

signals:
	void pictureUriChanged(QString uri);

private:
	DECLARE_ABSTRACT_OBJECT

	//--------------------------------------------------------------------------------
	// LINPHONE
	//--------------------------------------------------------------------------------
	virtual void onPresenceReceived(const std::shared_ptr<linphone::Friend> &contact) override;

signals:
	void presenceReceived(LinphoneEnums::ConsolidatedPresence consolidatedPresence, QDateTime presenceTimestamp);
};

#endif
