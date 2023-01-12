/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

#ifndef FILE_MEDIA_MODEL_H_
#define FILE_MEDIA_MODEL_H_

#include <QDateTime>
#include <QObject>
#include <QFileInfo>
#include <QString>
#include <QSharedPointer>

// =============================================================================

class FileMediaModel : public QObject {
	Q_OBJECT
	Q_PROPERTY(QString baseName READ getBaseName CONSTANT)
	Q_PROPERTY(QStringList parsedBaseName READ getParsedBaseName CONSTANT)
	Q_PROPERTY(QString filePath READ getFilePath CONSTANT)
	Q_PROPERTY(QDateTime creationDateTime READ getCreationDateTime CONSTANT)
	Q_PROPERTY(FILE_TYPE type READ getType CONSTANT)
// App Custom
	Q_PROPERTY(int duration READ getDuration CONSTANT)
	Q_PROPERTY(QString from READ getFrom CONSTANT)
	Q_PROPERTY(QString to READ getTo CONSTANT)
public:
	enum FILE_TYPE{
		IS_CALL_RECORD,
		IS_VOICE_RECORD,
		IS_SNAPSHOT,
		IS_PLAYABLE,// playable but nor call nor voice
		IS_UNKNOWN
	};
	Q_ENUM(FILE_TYPE)
	FileMediaModel(const QString& path, QObject * parent = nullptr);
	FileMediaModel(const QFileInfo& fileInfo, QObject * parent = nullptr);
	~FileMediaModel();
	static QSharedPointer<FileMediaModel> create(const QString& path);
	static QSharedPointer<FileMediaModel> create(const QFileInfo& fileInfo);
	
	void init();
	
	QString getBaseName() const;
	QString getFilePath() const;
	int getDuration() const;
	QDateTime getCreationDateTime() const;
	QStringList getParsedBaseName() const;
	FILE_TYPE getType()const;
	QString getFrom()const;
	QString getTo()const;
	
private:
	QFileInfo mFileInfo;
	int mDuration = -1;		// Set by LinphonePlayer when cration an instance of FileModel
	FILE_TYPE mType = IS_UNKNOWN;
};

#endif
