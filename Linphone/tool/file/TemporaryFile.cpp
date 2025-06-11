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

#include <QDebug>

#include "TemporaryFile.hpp"

#include "core/chat/message/content/ChatMessageContentCore.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Utils.hpp"

#include <linphone++/linphone.hh>

// =============================================================================

using namespace std;

DEFINE_ABSTRACT_OBJECT(TemporaryFile)

TemporaryFile::TemporaryFile(QObject *parent) : QObject(parent) {
}

TemporaryFile::~TemporaryFile() {
	deleteFile();
}

void TemporaryFile::createFileFromContent(std::shared_ptr<linphone::Content> content, const bool &exportPlainFile) {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	if (content) {
		QString filePath;
		if (exportPlainFile || (SettingsModel::getInstance()->getVfsEncrypted() && content->isFileEncrypted()))
			filePath = Utils::coreStringToAppString(content->exportPlainFile());
		bool toDelete = true;
		if (filePath.isEmpty()) {
			filePath = Utils::coreStringToAppString(content->getFilePath());
			toDelete = false;
			if (content->isFileEncrypted()) // filePath was empty while the file is encrypted : it couldn't be decoded.
				setIsReadable(false);
			else setIsReadable(true);
		} else setIsReadable(true);
		setFilePath(filePath, toDelete);
	}
}

void TemporaryFile::createFile(const QString &openFilePath, const bool &exportPlainFile) {
	createFileFromContent(linphone::Factory::get()->createContentFromFile(Utils::appStringToCoreString(openFilePath)),
	                      exportPlainFile);
}

QString TemporaryFile::getFilePath() const {
	return mFilePath;
}

bool TemporaryFile::isReadable() const {
	return mIsReadable;
}

void TemporaryFile::setFilePath(const QString &path, const bool &toDelete) {
	if (path != mFilePath) {
		deleteFile();
		mFilePath = path;
		mDeleteFile = toDelete;
		emit filePathChanged();
	}
}

void TemporaryFile::setIsReadable(const bool &isReadable) {
	if (isReadable != mIsReadable) {
		mIsReadable = isReadable;
		emit isReadableChanged();
	}
}

void TemporaryFile::deleteFile() {
	if (mDeleteFile && !mFilePath.isEmpty()) QFile::remove(mFilePath);
	mFilePath = "";
}
