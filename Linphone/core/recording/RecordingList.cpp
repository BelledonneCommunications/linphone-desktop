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

#include <linphone/core.h>
#include <mediastreamer2/msmediaplayer.h>

#include "RecordingCore.hpp"
#include "RecordingGui.hpp"
#include "RecordingList.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/core/CoreModel.hpp"
#include "model/setting/SettingsModel.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"

#include <QDir>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

DEFINE_ABSTRACT_OBJECT(RecordingList)

namespace {
const QStringList PlayableSuffixes = {"mkv", "mka", "wav"};
const int ReloadDebounceMs = 700;
const int RetryDelayMs = 3000;
const int MaxProbeRetries = 3;
} // namespace

QSharedPointer<RecordingList> RecordingList::create() {
	auto model = QSharedPointer<RecordingList>(new RecordingList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

RecordingList::RecordingList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mReloadTimer.setSingleShot(true);
	mReloadTimer.setInterval(ReloadDebounceMs);
	mRetryTimer.setSingleShot(true);
	mRetryTimer.setInterval(RetryDelayMs);
}

RecordingList::~RecordingList() {
	mustBeInMainThread("~" + getClassName());
	mModelConnection = nullptr;
}

void RecordingList::setSelf(QSharedPointer<RecordingList> me) {
	mModelConnection = SafeConnection<RecordingList, CoreModel>::create(me, CoreModel::getInstance());

	connect(&mReloadTimer, &QTimer::timeout, this, [this]() { emit lUpdate(); });
	connect(&mRetryTimer, &QTimer::timeout, this, [this]() { emit lUpdate(); });
	connect(&mWatcher, &QFileSystemWatcher::directoryChanged, this, [this]() { mReloadTimer.start(); });

	mModelConnection->makeConnectToCore(&RecordingList::lUpdate, [this]() {
		mustBeInMainThread(log().arg(Q_FUNC_INFO) + "lUpdate");
		emit listAboutToBeReset();
		emit loadingChanged(true);
		mModelConnection->invokeToModel([this]() {
			mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
			auto settingsModel = SettingsModel::getInstance();
			auto folder = settingsModel ? settingsModel->getSavedCallsFolder() : Paths::getCapturesDirPath();
			if (folder.isEmpty()) folder = Paths::getCapturesDirPath();

			auto *recordings = new QList<QSharedPointer<RecordingCore>>();
			QDir directory(folder);
			auto files = directory.entryInfoList(QDir::Files | QDir::NoDotAndDotDot, QDir::Time);
			MSMediaPlayer *prober = nullptr;
			if (!files.isEmpty()) {
				auto factory = linphone_core_get_ms_factory(CoreModel::getInstance()->getCore()->cPtr());
				if (factory) prober = ms_media_player_new(factory, nullptr, nullptr, nullptr);
				if (!prober) lWarning() << log().arg("No prober available, media info will not be read");
			}
			bool needRetry = false;
			for (const auto &file : files) {
				if (!PlayableSuffixes.contains(file.suffix().toLower())) continue;
				int duration = 0;
				bool isVideo = false;
				bool isValid = true;
				if (prober) {
					isValid =
					    ms_media_player_open(prober, Utils::appStringToCoreString(file.absoluteFilePath()).c_str());
					if (isValid) {
						auto probedDuration = ms_media_player_get_duration(prober);
						duration = probedDuration > 0 ? probedDuration : 0;
						isVideo = ms_media_player_has_video_track(prober);
						ms_media_player_close(prober);
					}
				}
				if (!isValid) {
					needRetry = true;
					lWarning() << log()
					                  .arg("Media %1 is not readable yet, keeping it without media info")
					                  .arg(file.absoluteFilePath());
				}
				auto recording = RecordingCore::create(file, duration, isVideo, isValid);
				if (!recording->mUsername.isEmpty())
					recording->mDisplayName = ToolModel::getDisplayName(recording->mUsername);
				recordings->append(recording);
			}
			if (prober) ms_media_player_free(prober);
			mModelConnection->invokeToCore([this, recordings, folder, needRetry]() {
				mustBeInMainThread(log().arg(Q_FUNC_INFO));
				beginResetModel();
				mList.clear();
				for (auto &recording : *recordings) {
					toConnect(recording.get());
					mList.append(recording);
				}
				endResetModel();
				delete recordings;
				watchFolder(folder);
				emit loadingChanged(false);
				if (!needRetry) mRetryCount = 0;
				else if (mRetryCount < MaxProbeRetries) {
					++mRetryCount;
					mRetryTimer.start();
				}
			});
		});
	});
	mModelConnection->makeConnectToModel(&CoreModel::callStateChanged,
	                                     [this](const std::shared_ptr<linphone::Core> &core,
	                                            const std::shared_ptr<linphone::Call> &call,
	                                            linphone::Call::State state, const std::string &message) {
		                                     if (state != linphone::Call::State::Released) return;
		                                     mModelConnection->invokeToCore([this]() { mReloadTimer.start(); });
	                                     });
	emit lUpdate();
}

void RecordingList::watchFolder(const QString &folder) {
	if (mFolder == folder && !mWatcher.directories().isEmpty()) return;
	if (!mWatcher.directories().isEmpty()) mWatcher.removePaths(mWatcher.directories());
	mFolder = folder;
	if (!folder.isEmpty() && QDir(folder).exists()) mWatcher.addPath(folder);
}

void RecordingList::toConnect(RecordingCore *recording) {
	connect(recording, &RecordingCore::removed, this, [this, recording]() { ListProxy::remove(recording); });
}

void RecordingList::removeAll() {
	auto items = getSharedList<RecordingCore>();
	for (auto &item : items)
		if (item) item->removeFile();
}

QHash<int, QByteArray> RecordingList::roleNames() const {
	QHash<int, QByteArray> roles;
	roles[Qt::DisplayRole] = "$modelData";
	roles[Qt::DisplayRole + 1] = "$sectionMonth";
	return roles;
}

QVariant RecordingList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	auto recording = mList[row].objectCast<RecordingCore>();
	if (!recording) return QVariant();
	if (role == Qt::DisplayRole) return QVariant::fromValue(new RecordingGui(recording));
	else if (role == Qt::DisplayRole + 1) {
		auto dateTime = recording->mDateTime;
		if (dateTime.date().year() != QDate::currentDate().year()) return Utils::toDateMonthAndYearString(dateTime);
		else return Utils::toDateMonthString(dateTime);
	}
	return QVariant();
}
