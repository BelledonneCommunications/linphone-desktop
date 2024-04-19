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
#include <QDirIterator>
#include <QFileSelector>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QLibraryInfo>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlFileSelector>
#include <QQuickWindow>
#include <QTimer>

#include "core/account/AccountCore.hpp"
#include "core/account/AccountProxy.hpp"
#include "core/call-history/CallHistoryProxy.hpp"
#include "core/call/CallCore.hpp"
#include "core/call/CallGui.hpp"
#include "core/call/CallList.hpp"
#include "core/call/CallProxy.hpp"
#include "core/camera/CameraGui.hpp"
#include "core/conference/ConferenceGui.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "core/conference/ConferenceInfoProxy.hpp"
#include "core/fps-counter/FPSCounter.hpp"
#include "core/friend/FriendCore.hpp"
#include "core/friend/FriendGui.hpp"
#include "core/logger/QtLogger.hpp"
#include "core/login/LoginPage.hpp"
#include "core/notifier/Notifier.hpp"
#include "core/participant/ParticipantDeviceCore.hpp"
#include "core/participant/ParticipantDeviceProxy.hpp"
#include "core/participant/ParticipantGui.hpp"
#include "core/participant/ParticipantProxy.hpp"
#include "core/phone-number/PhoneNumber.hpp"
#include "core/phone-number/PhoneNumberProxy.hpp"
#include "core/search/MagicSearchProxy.hpp"
#include "core/setting/SettingsCore.hpp"
#include "core/singleapplication/singleapplication.h"
#include "core/timezone/TimeZone.hpp"
#include "core/timezone/TimeZoneProxy.hpp"
#include "core/variant/VariantList.hpp"
#include "model/object/VariantObject.hpp"
#include "tool/Constants.hpp"
#include "tool/EnumsToString.hpp"
#include "tool/Utils.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include "tool/providers/ImageProvider.hpp"
#include "tool/thread/Thread.hpp"

DEFINE_ABSTRACT_OBJECT(App)

App::App(int &argc, char *argv[])
    : SingleApplication(argc, argv, true, Mode::User | Mode::ExcludeAppPath | Mode::ExcludeAppVersion) {
	// Ignore vertical sync. This way, we avoid blinking on resizes(and other refresh like layouts etc.).
	auto ignoreVSync = QSurfaceFormat::defaultFormat();
	ignoreVSync.setSwapInterval(0);
	QSurfaceFormat::setDefaultFormat(ignoreVSync);
	lInfo() << "Loading Fonts";
	QDirIterator it(":/font/", QDirIterator::Subdirectories);
	while (it.hasNext()) {
		QString ttf = it.next();
		// lDebug()<< ttf;
		auto id = QFontDatabase::addApplicationFont(ttf);
	}

	//-------------------
	mLinphoneThread = new Thread(this);
	init();
	lInfo() << QStringLiteral("Starting application " APPLICATION_NAME " (bin: " EXECUTABLE_NAME
	                          "). Version:%1 Os:%2 Qt:%3")
	               .arg(applicationVersion())
	               .arg(Utils::getOsProduct())
	               .arg(qVersion());
}

App::~App() {
}

void App::setSelf(QSharedPointer<App>(me)) {
	mCoreModelConnection = QSharedPointer<SafeConnection<App, CoreModel>>(
	    new SafeConnection<App, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);
	mCoreModelConnection->makeConnectToModel(&CoreModel::callCreated,
	                                         [this](const std::shared_ptr<linphone::Call> &call) {
		                                         auto callCore = CallCore::create(call);
		                                         mCoreModelConnection->invokeToCore([this, callCore] {
			                                         auto callGui = new CallGui(callCore);
			                                         auto win = getCallsWindow(QVariant::fromValue(callGui));
			                                         Utils::smartShowWindow(win);
			                                         lDebug() << "App : call created" << callGui;
		                                         });
	                                         });
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
	connect(
	    mLinphoneThread, &QThread::started, coreModel.get(),
	    [this, coreModel]() mutable {
		    coreModel->start();
		    auto settings = Settings::create();
		    QMetaObject::invokeMethod(App::getInstance()->thread(), [this, settings]() mutable {
			    mSettings = settings;
			    settings.reset();

			    // QML
			    mEngine = new QQmlApplicationEngine(this);
			    // Provide `+custom` folders for custom components and `5.9` for old components.
			    QStringList selectors("custom");
			    const QVersionNumber &version = QLibraryInfo::version();
			    if (version.majorVersion() == 5 && version.minorVersion() == 9) selectors.push_back("5.9");
			    auto selector = new QQmlFileSelector(mEngine, mEngine);
			    selector->setExtraSelectors(selectors);
			    lInfo() << log().arg("Activated selectors:") << selector->selector()->allSelectors();

			    mEngine->addImportPath(":/");
			    mEngine->rootContext()->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
			    initCppInterfaces();
			    mEngine->addImageProvider(ImageProvider::ProviderId, new ImageProvider());
			    mEngine->addImageProvider(AvatarProvider::ProviderId, new AvatarProvider());

			    // Enable notifications.
			    mNotifier = new Notifier(mEngine);

			    const QUrl url(u"qrc:/Linphone/view/App/Main.qml"_qs);
			    QObject::connect(
			        mEngine, &QQmlApplicationEngine::objectCreated, this,
			        [this, url](QObject *obj, const QUrl &objUrl) {
				        if (url == objUrl) {
					        if (!obj) {
						        lCritical() << log().arg("Main.qml couldn't be load. The app will exit");
						        exit(-1);
					        }
					        mMainWindow = qobject_cast<QQuickWindow *>(obj);
					        Q_ASSERT(mMainWindow);
				        }
			        },
			        Qt::QueuedConnection);
			    mEngine->load(url);
		    });
		    // coreModel.reset();
	    },
	    Qt::SingleShotConnection);
	// Console Commands
	createCommandParser();
	mParser->parse(this->arguments());
	// TODO : Update languages for command translations.

	createCommandParser(); // Recreate parser in order to use translations from config.
	mParser->process(*this);

	if (mParser->isSet("verbose")) QtLogger::enableVerbose(true);
	if (mParser->isSet("qt-logs-only")) QtLogger::enableQtOnly(true);

	if (!mLinphoneThread->isRunning()) {
		lDebug() << log().arg("Starting Thread");
		mLinphoneThread->start();
	}
	setQuitOnLastWindowClosed(true); // TODO: use settings to set it

	lInfo() << log().arg("Display server : %1").arg(platformName());

	// mEngine->load(u"qrc:/Linphone/view/Prototype/CameraPrototype.qml"_qs);
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
	qmlRegisterSingletonType<EnumsToString>(
	    "EnumsToStringCpp", 1, 0, "EnumsToStringCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new EnumsToString(engine); });

	qmlRegisterSingletonType<Settings>(
	    "SettingsCpp", 1, 0, "SettingsCpp",
	    [this](QQmlEngine *engine, QJSEngine *) -> QObject * { return mSettings.get(); });

	qmlRegisterType<PhoneNumberProxy>(Constants::MainQmlUri, 1, 0, "PhoneNumberProxy");
	qmlRegisterType<VariantObject>(Constants::MainQmlUri, 1, 0, "VariantObject");
	qmlRegisterType<VariantList>(Constants::MainQmlUri, 1, 0, "VariantList");

	qmlRegisterType<ParticipantProxy>(Constants::MainQmlUri, 1, 0, "ParticipantProxy");
	qmlRegisterType<ParticipantGui>(Constants::MainQmlUri, 1, 0, "ParticipantGui");
	qmlRegisterType<ConferenceInfoProxy>(Constants::MainQmlUri, 1, 0, "ConferenceInfoProxy");
	qmlRegisterType<ConferenceInfoGui>(Constants::MainQmlUri, 1, 0, "ConferenceInfoGui");

	qmlRegisterType<PhoneNumberProxy>(Constants::MainQmlUri, 1, 0, "PhoneNumberProxy");
	qmlRegisterUncreatableType<PhoneNumber>(Constants::MainQmlUri, 1, 0, "PhoneNumber", QLatin1String("Uncreatable"));
	qmlRegisterType<AccountProxy>(Constants::MainQmlUri, 1, 0, "AccountProxy");
	qmlRegisterType<AccountGui>(Constants::MainQmlUri, 1, 0, "AccountGui");
	qmlRegisterUncreatableType<AccountCore>(Constants::MainQmlUri, 1, 0, "AccountCore", QLatin1String("Uncreatable"));
	qmlRegisterUncreatableType<CallCore>(Constants::MainQmlUri, 1, 0, "CallCore", QLatin1String("Uncreatable"));
	qmlRegisterType<CallProxy>(Constants::MainQmlUri, 1, 0, "CallProxy");
	qmlRegisterType<CallHistoryProxy>(Constants::MainQmlUri, 1, 0, "CallHistoryProxy");
	qmlRegisterType<CallGui>(Constants::MainQmlUri, 1, 0, "CallGui");
	qmlRegisterUncreatableType<ConferenceCore>(Constants::MainQmlUri, 1, 0, "ConferenceCore",
	                                           QLatin1String("Uncreatable"));
	qmlRegisterType<ConferenceGui>(Constants::MainQmlUri, 1, 0, "ConferenceGui");
	qmlRegisterType<FriendGui>(Constants::MainQmlUri, 1, 0, "FriendGui");
	qmlRegisterUncreatableType<FriendCore>(Constants::MainQmlUri, 1, 0, "FriendCore", QLatin1String("Uncreatable"));
	qmlRegisterType<MagicSearchProxy>(Constants::MainQmlUri, 1, 0, "MagicSearchProxy");
	qmlRegisterType<CameraGui>(Constants::MainQmlUri, 1, 0, "CameraGui");
	qmlRegisterType<FPSCounter>(Constants::MainQmlUri, 1, 0, "FPSCounter");

	qmlRegisterType<TimeZoneProxy>(Constants::MainQmlUri, 1, 0, "TimeZoneProxy");

	qmlRegisterType<ParticipantDeviceGui>(Constants::MainQmlUri, 1, 0, "ParticipantDeviceGui");
	qmlRegisterType<ParticipantDeviceProxy>(Constants::MainQmlUri, 1, 0, "ParticipantDeviceProxy");

	LinphoneEnums::registerMetaTypes();
}

//------------------------------------------------------------

void App::clean() {
	// Wait 500ms to let time for log te be stored.
	// mNotifier destroyed in mEngine deletion as it is its parent
	delete mEngine;
	mEngine = nullptr;
	if (mSettings) {
		mSettings->deleteLater();
		mSettings = nullptr;
	}
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

bool App::notify(QObject *receiver, QEvent *event) {
	bool done = true;
	try {
		done = QApplication::notify(receiver, event);
	} catch (const std::exception &ex) {
		lCritical() << log().arg("Exception has been catch in notify");
	} catch (...) {
		lCritical() << log().arg("Generic exeption has been catch in notify");
	}
	return done;
}

QQuickWindow *App::getCallsWindow(QVariant callGui) {
	mustBeInMainThread(getClassName());
	if (!mCallsWindow) {
		const QUrl callUrl("qrc:/Linphone/view/App/CallsWindow.qml");

		lInfo() << log().arg("Creating subwindow: `%1`.").arg(callUrl.toString());

		QQmlComponent component(mEngine, callUrl);
		if (component.isError()) {
			qWarning() << component.errors();
			abort();
		}
		lInfo() << log().arg("Subwindow status: `%1`.").arg(component.status());

		QObject *object = nullptr;
		// if (!callGui.isNull() && callGui.isValid()) object = component.createWithInitialProperties({{"call",
		// callGui}});
		object = component.create();
		Q_ASSERT(object);
		if (!object) {
			lCritical() << log().arg("Calls window could not be created.");
			return nullptr;
		}

		// QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
		object->setParent(mEngine);

		auto window = qobject_cast<QQuickWindow *>(object);
		Q_ASSERT(window);
		if (!window) {
			lCritical() << log().arg("Calls window could not be created.");
			return nullptr;
		}
		// window->setParent(mMainWindow);
		mCallsWindow = window;
	}
	if (!callGui.isNull() && callGui.isValid()) mCallsWindow->setProperty("call", callGui);
	return mCallsWindow;
}

void App::setCallsWindowProperty(const char *id, QVariant property) {
	if (mCallsWindow) mCallsWindow->setProperty(id, property);
}

void App::closeCallsWindow() {
	if (mCallsWindow) {
		mCallsWindow->close();
		mCallsWindow->deleteLater();
		mCallsWindow = nullptr;
	}
}

QQuickWindow *App::getMainWindow() {
	return mMainWindow;
}
