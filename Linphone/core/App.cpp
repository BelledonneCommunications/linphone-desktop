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

#include "App.hpp"

#include <QCoreApplication>

#include "core/logger/QtLogger.hpp"
#include "core/singleapplication/singleapplication.h"
#include "tool/Constants.hpp"
#include "view/Page/LoginPage.hpp"

App::App(int &argc, char *argv[])
    : SingleApplication(argc, argv, true, Mode::User | Mode::ExcludeAppPath | Mode::ExcludeAppVersion) {
	mLinphoneThread = new Thread(this);
	init();
	qDebug() << "[App] Starting Thread";
	mLinphoneThread->start();
}

//-----------------------------------------------------------
//		Initializations
//-----------------------------------------------------------

void App::init() {
	// Core. Manage the logger so it must be instantiate at first.
	mCoreModel = QSharedPointer<CoreModel>::create("", mLinphoneThread);

	// Console Commands
	createCommandParser();
	mParser->parse(this->arguments());
	// TODO : Update languages for command translations.

	createCommandParser(); // Recreate parser in order to use translations from config.
	mParser->process(*this);

	if (mParser->isSet("verbose")) QtLogger::enableVerbose(true);
	if (mParser->isSet("qt-logs-only")) QtLogger::enableQtOnly(true);

	connect(mLinphoneThread, &QThread::started, mCoreModel.get(), &CoreModel::start);
	// QML
	mEngine = new QQmlApplicationEngine(this);
	mEngine->addImportPath(":/");

	initCppInterfaces();

	const QUrl url(u"qrc:/Linphone/view/App/Main.qml"_qs);
	QObject::connect(
	    mEngine, &QQmlApplicationEngine::objectCreated, this,
	    [url](QObject *obj, const QUrl &objUrl) {
		    if (!obj && url == objUrl) QCoreApplication::exit(-1);
	    },
	    Qt::QueuedConnection);
	mEngine->load(url);
}

void App::initCppInterfaces() {
	qmlRegisterSingletonType<LoginPage>(
	    Constants::MainQmlUri, 1, 0, "LoginPageCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new LoginPage(engine); });
}

//------------------------------------------------------------
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
