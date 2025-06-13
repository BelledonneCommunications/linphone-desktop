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

#ifndef RECORDER_GUI_H_
#define RECORDER_GUI_H_

#include "RecorderCore.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <QSharedPointer>

class RecorderGui : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(RecorderCore *core READ getCore CONSTANT)

public:
	RecorderGui(QObject *parent = nullptr);
	RecorderGui(QSharedPointer<RecorderCore> core);
	~RecorderGui();
	RecorderCore *getCore() const;
	LinphoneEnums::RecorderState getState() const;
	QSharedPointer<RecorderCore> mCore;

signals:
	void errorChanged(QString error);
	void ready();
	void stateChanged(LinphoneEnums::RecorderState state);

private:
	DECLARE_ABSTRACT_OBJECT
};

#endif
