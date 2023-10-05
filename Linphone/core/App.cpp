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

#include "tool/Constants.hpp"
#include "view/Page/LoginPage.hpp"

App::App(QObject *parent) : QObject(parent) {
	mLinphoneThread = new Thread(this);
	init();
	qDebug() << "Starting Thread";
	mLinphoneThread->start();
}

//-----------------------------------------------------------
//		Initializations
//-----------------------------------------------------------

void App::init() {
	// Core
	mCoreModel = QSharedPointer<CoreModel>::create("", mLinphoneThread);

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
