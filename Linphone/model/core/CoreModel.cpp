/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#include "CoreModel.hpp"

#include <QApplication>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QSysInfo>
#include <QTimer>

#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "tool/Utils.hpp"

// =============================================================================

QSharedPointer<CoreModel> CoreModel::gCoreModel;

CoreModel::CoreModel(const QString &configPath, QThread *parent) : QObject() {
	connect(parent, &QThread::finished, this, [this]() {
		// Model thread
		if (mCore && mCore->getGlobalState() == linphone::GlobalState::On) mCore->stop();
		gCoreModel = nullptr;
	});
	mConfigPath = configPath;
	mLogger = std::make_shared<LoggerModel>(this);
	mLogger->init();
	moveToThread(parent);
}

CoreModel::~CoreModel() {
}

QSharedPointer<CoreModel> CoreModel::create(const QString &configPath, QThread *parent) {
	auto model = QSharedPointer<CoreModel>::create(configPath, parent);
	gCoreModel = model;
	return model;
}

void CoreModel::start() {
	mIterateTimer = new QTimer(this);
	mIterateTimer->setInterval(30);
	connect(mIterateTimer, &QTimer::timeout, [this]() { mCore->iterate(); });
	setPathBeforeCreation();
	mCore =
	    linphone::Factory::get()->createCore(Utils::appStringToCoreString(Paths::getConfigFilePath(mConfigPath)),
	                                         Utils::appStringToCoreString(Paths::getFactoryConfigFilePath()), nullptr);
	setPathsAfterCreation();
	mCore->start();
	setPathAfterStart();
	mIterateTimer->start();
}
// -----------------------------------------------------------------------------

QSharedPointer<CoreModel> CoreModel::getInstance() {
	return gCoreModel;
}

std::shared_ptr<linphone::Core> CoreModel::getCore() {
	return mCore;
}

//-------------------------------------------------------------------------------
void CoreModel::setConfigPath(QString path) {
	if (mConfigPath != path) {
		mConfigPath = path;
		if (!mCore) {
			qWarning() << "[CoreModel] Setting config path after core creation is not yet supported";
		}
	}
}

//-------------------------------------------------------------------------------
//				PATHS
//-------------------------------------------------------------------------------
#define SET_FACTORY_PATH(TYPE, PATH)                                                                                   \
	do {                                                                                                               \
		qInfo() << QStringLiteral("[CoreModel] Set `%1` factory path: `%2`").arg(#TYPE).arg(PATH);                     \
		factory->set##TYPE##Dir(Utils::appStringToCoreString(PATH));                                                   \
	} while (0);

void CoreModel::setPathBeforeCreation() {
	std::shared_ptr<linphone::Factory> factory = linphone::Factory::get();
	SET_FACTORY_PATH(Msplugins, Paths::getPackageMsPluginsDirPath());
	SET_FACTORY_PATH(TopResources, Paths::getPackageTopDirPath());
	SET_FACTORY_PATH(SoundResources, Paths::getPackageSoundsResourcesDirPath());
	SET_FACTORY_PATH(DataResources, Paths::getPackageDataDirPath());
	SET_FACTORY_PATH(Data, Paths::getAppLocalDirPath());
	SET_FACTORY_PATH(Download, Paths::getDownloadDirPath());
	SET_FACTORY_PATH(Config, Paths::getConfigDirPath(true));
}

void CoreModel::setPathsAfterCreation() {
	QString friendsDb = Paths::getFriendsListFilePath();
	qInfo() << QStringLiteral("[CoreModel] Set Database `Friends` path: `%1`").arg(friendsDb);
	mCore->setFriendsDatabasePath(Utils::appStringToCoreString(friendsDb));
}

void CoreModel::setPathAfterStart() {
	// Use application path if Linphone default is not available
	if (mCore->getZrtpSecretsFile().empty() ||
	    !Paths::filePathExists(Utils::coreStringToAppString(mCore->getZrtpSecretsFile()), true))
		mCore->setZrtpSecretsFile(Utils::appStringToCoreString(Paths::getZrtpSecretsFilePath()));
	qInfo() << "[CoreModel] Using ZrtpSecrets path : " << QString::fromStdString(mCore->getZrtpSecretsFile());
	// Use application path if Linphone default is not available
	if (mCore->getUserCertificatesPath().empty() ||
	    !Paths::filePathExists(Utils::coreStringToAppString(mCore->getUserCertificatesPath()), true))
		mCore->setUserCertificatesPath(Utils::appStringToCoreString(Paths::getUserCertificatesDirPath()));
	qInfo() << "[CoreModel] Using UserCertificate path : " << QString::fromStdString(mCore->getUserCertificatesPath());
	// Use application path if Linphone default is not available
	if (mCore->getRootCa().empty() || !Paths::filePathExists(Utils::coreStringToAppString(mCore->getRootCa())))
		mCore->setRootCa(Utils::appStringToCoreString(Paths::getRootCaFilePath()));
	qInfo() << "[CoreModel] Using RootCa path : " << QString::fromStdString(mCore->getRootCa());
}
