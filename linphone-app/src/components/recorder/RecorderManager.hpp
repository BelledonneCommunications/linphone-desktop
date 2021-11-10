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

#ifndef RECORDER_MANAGER_MODEL_H
#define RECORDER_MANAGER_MODEL_H


#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================
class RecorderModel;

class RecorderManager : public QObject {
	Q_OBJECT
public:
	RecorderManager (QObject * parent = nullptr);
	virtual ~RecorderManager();
	
	Q_PROPERTY(bool haveVocalRecorder READ haveVocalRecorder NOTIFY haveVocalRecorderChanged)

	bool haveVocalRecorder() const;
	Q_INVOKABLE RecorderModel* getVocalRecorder();
	Q_INVOKABLE RecorderModel* resetVocalRecorder();
	Q_INVOKABLE void clearVocalRecorder();
	
signals:
	void haveVocalRecorderChanged();
	
private:
	std::shared_ptr<RecorderModel> mVocalRecorder;
};
#endif
