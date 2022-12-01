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

#ifndef TEMPORARY_FILE_H_
#define TEMPORARY_FILE_H_

#include <QFile>

// =============================================================================

class ContentModel;

class TemporaryFile : public QObject {
	Q_OBJECT
public:
	TemporaryFile (QObject *parent = nullptr);
	~TemporaryFile ();
	
	Q_PROPERTY(QString filePath READ getFilePath NOTIFY filePathChanged)// not changeable from QML as it comes from a ContentModel
	
	Q_INVOKABLE void createFileFromContent(ContentModel * contentModel, const bool& exportPlainFile = true);
	
	QString getFilePath () const;
	void setFilePath(const QString& path, const bool& toDelete);
	
	void deleteFile();
	
signals :
	void filePathChanged();
	
private:
	QString mFilePath;
	bool mDeleteFile = false;
};

#endif
