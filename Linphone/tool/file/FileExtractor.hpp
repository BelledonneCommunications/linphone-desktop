/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef FILE_EXTRACTOR_H_
#define FILE_EXTRACTOR_H_

#include <QFile>

// =============================================================================

class QTimer;

// Supports only bzip file.
class FileExtractor : public QObject {

	Q_OBJECT;

	// TODO: Add an error property to use in UI.

	Q_PROPERTY(QString file READ getFile WRITE setFile NOTIFY fileChanged);
	Q_PROPERTY(QString extractFolder READ getExtractFolder WRITE setExtractFolder NOTIFY extractFolderChanged);
	Q_PROPERTY(QString extractName READ getExtractName WRITE setExtractName NOTIFY extractNameChanged);
	Q_PROPERTY(bool extracting READ getExtracting NOTIFY extractingChanged);
	Q_PROPERTY(qint64 readBytes READ getReadBytes NOTIFY readBytesChanged);
	Q_PROPERTY(qint64 totalBytes READ getTotalBytes NOTIFY totalBytesChanged);

public:
	FileExtractor(QObject *parent = nullptr);
	~FileExtractor();

	Q_INVOKABLE void extract();
	Q_INVOKABLE bool remove();

	QString getFile() const;
	void setFile(const QString &file);

	QString getExtractFolder() const;
	void setExtractFolder(const QString &extractFolder);

	QString getExtractName() const;
	void setExtractName(const QString &extractName);

signals:
	void fileChanged(const QString &file);

	void extractFolderChanged(const QString &extractFolder);
	void extractNameChanged(const QString &extractName);

	void readBytesChanged(qint64 readBytes);
	void totalBytesChanged(qint64 totalBytes);

	void extractingChanged(bool extracting);
	void extractFinished();
	void extractFailed();

private:
	qint64 getReadBytes() const;
	void setReadBytes(qint64 readBytes);

	qint64 getTotalBytes() const;
	void setTotalBytes(qint64 totalBytes);

	bool getExtracting() const;
	void setExtracting(bool extracting);

	void clean();

	void emitExtractFinished();
	void emitExtractorFailed(); // Used when bzip2 cannot be used
	void emitExtractFailed(int error);
	void emitOutputError();

	void handleExtraction();

	QString mFile;
	QString mExtractFolder;
	QString mExtractName;
	QString mDestinationFile;

	bool mExtracting = false;
	qint64 mReadBytes = 0;
	qint64 mTotalBytes = 0;

	QTimer *mTimer = nullptr;
};

#endif // FILE_EXTRACTOR_H_
