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

#ifndef RECORDER_CORE_H
#define RECORDER_CORE_H

#include "model/recorder/RecorderModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <linphone++/linphone.hh>

// =============================================================================

class RecorderCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	static QSharedPointer<RecorderCore> create(QObject *parent = nullptr);
	RecorderCore(QObject *parent = nullptr);
	~RecorderCore();
	void setSelf(QSharedPointer<RecorderCore> me);

	Q_PROPERTY(LinphoneEnums::RecorderState state READ getState NOTIFY stateChanged)
	Q_PROPERTY(QString file READ getFile NOTIFY fileChanged)
	Q_PROPERTY(int duration READ getDuration NOTIFY durationChanged)
	Q_PROPERTY(int captureVolume READ getCaptureVolume NOTIFY captureVolumeChanged)

	void buildRecorder(QSharedPointer<RecorderCore> me);

	int getDuration() const;
	void setDuration(int duration);
	float getCaptureVolume() const;
	void setCaptureVolume(float volume);
	LinphoneEnums::RecorderState getState() const;
	void setState(LinphoneEnums::RecorderState state);
	QString getFile() const;
	void setFile(QString file);
	const std::shared_ptr<RecorderModel> &getModel() const;

signals:
	void lStart();
	void lPause();
	void lStop();
	void lRefresh();

	void stateChanged(LinphoneEnums::RecorderState state);
	void fileChanged();
	void durationChanged();
	void captureVolumeChanged();
	void errorChanged(QString error);
	void ready();

private:
	DECLARE_ABSTRACT_OBJECT

	std::shared_ptr<RecorderModel> mRecorderModel;
	QString mFile;
	LinphoneEnums::RecorderState mState;
	int mDuration = 0;
	int mCaptureVolume = 0;
	bool mIsReady = false;
	QSharedPointer<SafeConnection<RecorderCore, RecorderModel>> mRecorderModelConnection;
	QSharedPointer<SafeConnection<RecorderCore, CoreModel>> mCoreModelConnection;
};
#endif
