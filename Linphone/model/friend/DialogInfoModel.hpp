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

#ifndef DIALOG_INFO_MODEL_H_
#define DIALOG_INFO_MODEL_H_

#include <QMetaType>
#include <QString>

// Parses "application/dialog-info+xml" NOTIFY bodies (RFC 4235), as sent by Asterisk/MikoPBX for BLF subscriptions.
class DialogInfoModel {
public:
	enum class State {
		Unknown, // Could not parse, or no <dialog> element present
		Idle,    // No active dialog => extension is free
		Ringing, // <state>early</state> => extension is ringing
		InCall   // <state>confirmed</state> => extension is busy/on a call
	};

	// Returns Unknown if the body isn't well-formed dialog-info+xml.
	static State parse(const QString &xmlBody);

	static bool isBusy(State state) {
		return state == State::InCall;
	}
};

// Not a QObject enum, so it needs this to cross the model->UI queued connection (see SafeConnection).
Q_DECLARE_METATYPE(DialogInfoModel::State)

#endif
