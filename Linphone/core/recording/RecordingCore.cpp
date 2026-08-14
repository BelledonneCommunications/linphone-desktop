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

#include "RecordingCore.hpp"
#include "core/App.hpp"

#include <QDir>
#include <QFile>
#include <QRegularExpression>
#include <QTimeZone>

DEFINE_ABSTRACT_OBJECT(RecordingCore)

QSharedPointer<RecordingCore> RecordingCore::create(
    const QFileInfo &fileInfo, int durationMs, bool isVideo, bool isValid, const QString &displayName) {
	auto sharedPointer = QSharedPointer<RecordingCore>(new RecordingCore(fileInfo), &QObject::deleteLater);
	sharedPointer->mDuration = durationMs;
	sharedPointer->mIsVideo = isVideo;
	sharedPointer->mIsValid = isValid;
	if (!displayName.isEmpty()) sharedPointer->mDisplayName = displayName;
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

RecordingCore::RecordingCore(const QFileInfo &fileInfo) : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mFilePath = fileInfo.absoluteFilePath();
	mFileName = fileInfo.fileName();
	mDateTime = fileInfo.birthTime().isValid() ? fileInfo.birthTime() : fileInfo.lastModified();
	parseFileName();
}

RecordingCore::~RecordingCore() {
	mustBeInMainThread("~" + getClassName());
}

void RecordingCore::parseFileName() {
	static QRegularExpression nameRegexp(
	    "^(?:[A-Za-z]+_)?(\\d{4}-\\d{2}-\\d{2})_(\\d{2}-\\d{2}-\\d{2})(?:-\\d+)?_?(.*)$");
	auto baseName = QFileInfo(mFilePath).completeBaseName();
	auto match = nameRegexp.match(baseName);
	if (!match.hasMatch()) {
		mDisplayName = baseName;
		return;
	}
	auto parsedDate =
	    QDateTime::fromString(match.captured(1) + "_" + match.captured(2), QStringLiteral("yyyy-MM-dd_hh-mm-ss"));
	if (parsedDate.isValid()) {
		parsedDate.setTimeZone(QTimeZone::systemTimeZone());
		mDateTime = parsedDate;
	}
	auto peers = match.captured(3);
	auto separatorIndex = peers.lastIndexOf('_');
	mUsername = separatorIndex == -1 ? peers : peers.left(separatorIndex);
	if (mUsername.isEmpty()) mUsername = separatorIndex == -1 ? QString() : peers.mid(separatorIndex + 1);
	mDisplayName = mUsername.isEmpty() ? baseName : mUsername;
}

void RecordingCore::setDisplayName(const QString &displayName) {
	if (displayName.isEmpty() || displayName == mDisplayName) return;
	mDisplayName = displayName;
	emit displayNameChanged();
}

void RecordingCore::setMediaInfo(int durationMs, bool isVideo, bool isValid) {
	if (mDuration == durationMs && mIsVideo == isVideo && mIsValid == isValid) return;
	mDuration = durationMs;
	mIsVideo = isVideo;
	mIsValid = isValid;
	emit mediaInfoChanged();
}

QString RecordingCore::buildDurationString(int durationMs) {
	auto totalSeconds = durationMs / 1000;
	auto hours = totalSeconds / 3600;
	auto minutes = (totalSeconds % 3600) / 60;
	auto seconds = totalSeconds % 60;
	if (hours > 0)
		return QStringLiteral("%1:%2:%3")
		    .arg(hours)
		    .arg(minutes, 2, 10, QLatin1Char('0'))
		    .arg(seconds, 2, 10, QLatin1Char('0'));
	return QStringLiteral("%1:%2").arg(minutes, 2, 10, QLatin1Char('0')).arg(seconds, 2, 10, QLatin1Char('0'));
}

QString RecordingCore::getDurationString() const {
	return buildDurationString(mDuration);
}

bool RecordingCore::removeFile() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	QFile file(mFilePath);
	if (file.exists() && !file.remove()) {
		lWarning() << log().arg("Unable to delete %1 : %2").arg(mFilePath).arg(file.errorString());
		return false;
	}
	emit removed();
	return true;
}

bool RecordingCore::exportTo(const QString &destinationPath) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (destinationPath.isEmpty()) return false;
	QFileInfo destination(destinationPath);
	auto finalPath = destination.isDir() ? QDir(destinationPath).absoluteFilePath(mFileName) : destinationPath;
	if (QFileInfo(finalPath) == QFileInfo(mFilePath)) return true;
	QFile::remove(finalPath);
	if (!QFile::copy(mFilePath, finalPath)) {
		lWarning() << log().arg("Unable to export %1 to %2").arg(mFilePath).arg(finalPath);
		emit exportFailed(mFilePath);
		return false;
	}
	return true;
}
