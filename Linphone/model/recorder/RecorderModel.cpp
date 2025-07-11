﻿/*
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

#include "core/App.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "tool/Utils.hpp"

#include <QFile>
#include <QQmlApplicationEngine>

#include "RecorderModel.hpp"

DEFINE_ABSTRACT_OBJECT(RecorderModel)

// =============================================================================

RecorderModel::RecorderModel(std::shared_ptr<linphone::Recorder> recorder, QObject *parent) : QObject(parent) {
	mustBeInLinphoneThread(getClassName());
	mRecorder = recorder;
}

RecorderModel::~RecorderModel() {
}

std::shared_ptr<linphone::Recorder> RecorderModel::getRecorder() {
	return mRecorder;
}

int RecorderModel::getDuration() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mRecorder->getDuration();
}

float RecorderModel::getCaptureVolume() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mRecorder->getCaptureVolume();
}

linphone::Recorder::State RecorderModel::getState() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return mRecorder->getState();
}

QString RecorderModel::getFile() const {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	return Utils::coreStringToAppString(mRecorder->getFile());
}

QStringList RecorderModel::splitSavedFilename(const QString &filename) {
	QStringList fields = filename.split('_');
	if (fields.size() == 3 && fields[0] == "vocal" && fields[1].split('-').size() == 3 &&
	    fields[2].split('-').size() == 4) {
		return fields;
	} else return QStringList(filename);
}

QDateTime RecorderModel::getDateTimeSavedFilename(const QString &filename) {
	auto fields = splitSavedFilename(filename);
	if (fields.size() > 1) return QDateTime::fromString(fields[1] + "_" + fields[2], "yyyy-MM-dd_hh-mm-ss-zzz");
	else return QDateTime();
}

void RecorderModel::start() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	bool soFarSoGood;
	QString filename =
	    QStringLiteral("vocal_%1.mkv").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss-zzz"));
	const QString safeFilePath = Utils::getSafeFilePath(
	    QStringLiteral("%1%2").arg(SettingsModel::getInstance()->getSavedCallsFolder()).arg(filename), &soFarSoGood);

	if (!soFarSoGood) {
		qWarning() << QStringLiteral("Unable to create safe file path for: %1.").arg(filename);
		emit errorChanged(QString("Unable to create safe file path for : %1.").arg(filename));
	} else if (mRecorder->open(Utils::appStringToCoreString(safeFilePath)) < 0) {
		qWarning() << QStringLiteral("Unable to open safe file path for: %1.").arg(filename);
		emit errorChanged(QString("Unable to open safe file path for : %1.").arg(filename));
	} else if (mRecorder->start() < 0) {
		qWarning() << QStringLiteral("Unable to start recording to : %1.").arg(filename);
		emit errorChanged(QString("Unable to start recording to : %1.").arg(filename));
	}
	emit stateChanged();
	emit fileChanged();
}

void RecorderModel::pause() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mRecorder->pause();
	emit stateChanged();
}

void RecorderModel::stop() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	// if (mRecorder->getState() == linphone::Recorder::State::Running) // Remove these tests when the SDK do them.
	// mRecorder->pause();
	// if (mRecorder->getState() == linphone::Recorder::State::Paused) {
	mRecorder->close();
	emit stateChanged();
}

//--------------------------------------------------------------------------------------------------------------------------
