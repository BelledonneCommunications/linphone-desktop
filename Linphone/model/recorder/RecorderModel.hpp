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

#include "tool/AbstractObject.hpp"
#include <linphone++/linphone.hh>

// =============================================================================

class RecorderModel : public QObject, public AbstractObject {
	Q_OBJECT

public:
	RecorderModel(std::shared_ptr<linphone::Recorder> recorder, QObject *parent = nullptr);
	virtual ~RecorderModel();

	std::shared_ptr<linphone::Recorder> getRecorder();

	int getDuration() const;
	float getCaptureVolume() const;
	linphone::Recorder::State getState() const;
	QString getFile() const;

	static QStringList
	splitSavedFilename(const QString &filename); // If doesn't match to generateSavedFilename, return filename
	static QDateTime getDateTimeSavedFilename(const QString &filename);

	void start();
	void pause();
	void stop();

signals:
	void stateChanged();
	void fileChanged();
	void errorChanged(QString error);

private:
	DECLARE_ABSTRACT_OBJECT
	std::shared_ptr<linphone::Recorder> mRecorder;
};
#endif
