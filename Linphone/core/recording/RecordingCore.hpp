/*
 * Copyright (c) 2010-2026 Belledonne Communications SARL.
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

#ifndef RECORDING_CORE_H_
#define RECORDING_CORE_H_

#include "tool/AbstractObject.hpp"
#include <QDateTime>
#include <QFileInfo>
#include <QObject>
#include <QSharedPointer>

class RecordingCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString filePath MEMBER mFilePath CONSTANT)
	Q_PROPERTY(QString fileName MEMBER mFileName CONSTANT)
	Q_PROPERTY(QString displayName MEMBER mDisplayName NOTIFY displayNameChanged)
	Q_PROPERTY(QDateTime dateTime MEMBER mDateTime CONSTANT)
	Q_PROPERTY(int duration MEMBER mDuration NOTIFY mediaInfoChanged)
	Q_PROPERTY(QString durationString READ getDurationString NOTIFY mediaInfoChanged)
	Q_PROPERTY(bool isVideo MEMBER mIsVideo NOTIFY mediaInfoChanged)
	Q_PROPERTY(bool isValid MEMBER mIsValid NOTIFY mediaInfoChanged)

public:
	static QSharedPointer<RecordingCore> create(const QFileInfo &fileInfo,
	                                            int durationMs = 0,
	                                            bool isVideo = false,
	                                            bool isValid = true,
	                                            const QString &displayName = QString());
	RecordingCore(const QFileInfo &fileInfo);
	~RecordingCore();

	QString getDurationString() const;
	static QString buildDurationString(int durationMs);

	void setMediaInfo(int durationMs, bool isVideo, bool isValid);
	void setDisplayName(const QString &displayName);

	Q_INVOKABLE bool removeFile();
	Q_INVOKABLE bool exportTo(const QString &destinationPath);

	QString mFilePath;
	QString mFileName;
	QString mDisplayName;
	QString mUsername;
	QDateTime mDateTime;
	int mDuration = 0;
	bool mIsVideo = false;
	bool mIsValid = true;

signals:
	void displayNameChanged();
	void mediaInfoChanged();
	void removed();
	void exportFailed(QString filePath);

private:
	void parseFileName();

	DECLARE_ABSTRACT_OBJECT
};

Q_DECLARE_METATYPE(RecordingCore *)

#endif
