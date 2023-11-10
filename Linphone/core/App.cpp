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

#include "tool/LinphoneEnums.hpp"

#include "App.hpp"

#include <QCoreApplication>
#include <QFileSelector>
#include <QGuiApplication>
#include <QLibraryInfo>
#include <QQmlContext>
#include <QQmlFileSelector>
#include <QTimer>

#include "core/account/Account.hpp"
#include "core/account/AccountProxy.hpp"
#include "core/logger/QtLogger.hpp"
#include "core/login/LoginPage.hpp"
#include "core/notifier/Notifier.hpp"
#include "core/phone-number/PhoneNumber.hpp"
#include "core/phone-number/PhoneNumberProxy.hpp"
#include "core/singleapplication/singleapplication.h"
#include "model/object/VariantObject.hpp"
#include "tool/Constants.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/Thread.hpp"

#include "tool/providers/ImageProvider.hpp"

App::App(int &argc, char *argv[])
    : SingleApplication(argc, argv, true, Mode::User | Mode::ExcludeAppPath | Mode::ExcludeAppVersion) {
	mLinphoneThread = new Thread(this);
	init();
}

App *App::getInstance() {
	return dynamic_cast<App *>(QApplication::instance());
}

Notifier *App::getNotifier() const {
	return mNotifier;
}
//-----------------------------------------------------------
//		Initializations
//-----------------------------------------------------------

void App::init() {
	// Core. Manage the logger so it must be instantiate at first.
	auto coreModel = CoreModel::create("", mLinphoneThread);
	connect(mLinphoneThread, &QThread::started, coreModel.get(), &CoreModel::start);
	// Console Commands
	createCommandParser();
	mParser->parse(this->arguments());
	// TODO : Update languages for command translations.

	createCommandParser(); // Recreate parser in order to use translations from config.
	mParser->process(*this);

	if (mParser->isSet("verbose")) QtLogger::enableVerbose(true);
	if (mParser->isSet("qt-logs-only")) QtLogger::enableQtOnly(true);

	if (!mLinphoneThread->isRunning()) {
		qDebug() << "[App] Starting Thread";
		mLinphoneThread->start();
	}

	// QML
	mEngine = new QQmlApplicationEngine(this);
	// Provide `+custom` folders for custom components and `5.9` for old components.
	QStringList selectors("custom");
	const QVersionNumber &version = QLibraryInfo::version();
	if (version.majorVersion() == 5 && version.minorVersion() == 9) selectors.push_back("5.9");
	auto selector = new QQmlFileSelector(mEngine, mEngine);
	selector->setExtraSelectors(selectors);
	qInfo() << QStringLiteral("[App] Activated selectors:") << selector->selector()->allSelectors();

	mEngine->addImportPath(":/");
	mEngine->rootContext()->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
	initCppInterfaces();
	mEngine->addImageProvider(ImageProvider::ProviderId, new ImageProvider());

	// Enable notifications.
	mNotifier = new Notifier(mEngine);

	const QUrl url(u"qrc:/Linphone/view/App/Main.qml"_qs);
	QObject::connect(
	    mEngine, &QQmlApplicationEngine::objectCreated, this,
	    [url](QObject *obj, const QUrl &objUrl) {
		    if (!obj && url == objUrl) {
			    qCritical() << "[App] Main.qml couldn't be load. The app will exit";
			    exit(-1);
		    }
	    },
	    Qt::QueuedConnection);
	mEngine->load(url);
}

void App::initCppInterfaces() {
	qmlRegisterSingletonType<LoginPage>(
	    Constants::MainQmlUri, 1, 0, "LoginPageCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new LoginPage(engine); });
	qmlRegisterSingletonType<Constants>(
	    "ConstantsCpp", 1, 0, "ConstantsCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new Constants(engine); });
	qmlRegisterSingletonType<Utils>("UtilsCpp", 1, 0, "UtilsCpp",
	                                [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new Utils(engine); });

	qmlRegisterType<PhoneNumberProxy>(Constants::MainQmlUri, 1, 0, "PhoneNumberProxy");
	qmlRegisterType<VariantObject>(Constants::MainQmlUri, 1, 0, "VariantObject");

	qmlRegisterUncreatableType<PhoneNumber>(Constants::MainQmlUri, 1, 0, "PhoneNumber", QLatin1String("Uncreatable"));
	qmlRegisterType<AccountProxy>(Constants::MainQmlUri, 1, 0, "AccountProxy");
	qmlRegisterUncreatableType<Account>(Constants::MainQmlUri, 1, 0, "Account", QLatin1String("Uncreatable"));
	qmlRegisterUncreatableType<Call>(Constants::MainQmlUri, 1, 0, "Call", QLatin1String("Uncreatable"));

	LinphoneEnums::registerMetaTypes();
}

//------------------------------------------------------------

void App::clean() {
	// Wait 500ms to let time for log te be stored.
	mLinphoneThread->wait(250);
	qApp->processEvents(QEventLoop::AllEvents, 250);
	mLinphoneThread->exit();
	mLinphoneThread->wait();
	delete mLinphoneThread;
}

void App::createCommandParser() {
	if (!mParser) delete mParser;

	mParser = new QCommandLineParser();
	mParser->setApplicationDescription(tr("applicationDescription"));
	mParser->addPositionalArgument("command", tr("commandLineDescription").replace("%1", APPLICATION_NAME),
	                               "[command]");
	mParser->addOptions({
	    {{"h", "help"}, tr("commandLineOptionHelp")},
	    {"cli-help", tr("commandLineOptionCliHelp").replace("%1", APPLICATION_NAME)},
	    {{"v", "version"}, tr("commandLineOptionVersion")},
	    {"config", tr("commandLineOptionConfig").replace("%1", EXECUTABLE_NAME), tr("commandLineOptionConfigArg")},
	    {"fetch-config", tr("commandLineOptionFetchConfig").replace("%1", EXECUTABLE_NAME),
	     tr("commandLineOptionFetchConfigArg")},
	    {{"c", "call"}, tr("commandLineOptionCall").replace("%1", EXECUTABLE_NAME), tr("commandLineOptionCallArg")},
#ifndef Q_OS_MACOS
	    {"iconified", tr("commandLineOptionIconified")},
#endif // ifndef Q_OS_MACOS
	    {{"V", "verbose"}, tr("commandLineOptionVerbose")},
	    {"qt-logs-only", tr("commandLineOptionQtLogsOnly")},
	});
}
