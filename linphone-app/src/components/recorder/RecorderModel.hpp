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

#ifndef RECORDER_MODEL_H
#define RECORDER_MODEL_H

#include "utils/LinphoneEnums.hpp"

// =============================================================================


class RecorderModel : public QObject {
	Q_OBJECT
	
public:
	static std::shared_ptr<RecorderModel> create(std::shared_ptr<linphone::Recorder> recorder,QObject * parent = nullptr);// Call it instead constructor
	RecorderModel (std::shared_ptr<linphone::Recorder> recorder,QObject * parent = nullptr);
	virtual ~RecorderModel();
	
	Q_PROPERTY(LinphoneEnums::RecorderState state READ getState NOTIFY stateChanged)
	Q_PROPERTY(QString file READ getFile NOTIFY fileChanged)
	
	std::shared_ptr<linphone::Recorder> getRecorder();
	
	Q_INVOKABLE int getDuration()const;
	Q_INVOKABLE float getCaptureVolume()const;
	LinphoneEnums::RecorderState getState() const;
	Q_INVOKABLE QString getFile()const;
	
	static QStringList splitSavedFilename(const QString& filename);// If doesn't match to generateSavedFilename, return filename
	static QDateTime getDateTimeSavedFilename(const QString& filename);
	
	Q_INVOKABLE void start();
	Q_INVOKABLE void pause();
	Q_INVOKABLE void stop();
	
signals:
	void stateChanged();
	void fileChanged();
	
private:
	std::shared_ptr<linphone::Recorder> mRecorder;
};
Q_DECLARE_METATYPE(std::shared_ptr<RecorderModel>)
Q_DECLARE_METATYPE(RecorderModel*)
#endif
