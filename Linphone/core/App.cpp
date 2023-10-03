#include "App.hpp"

#include <QCoreApplication>

#include "tool/Constants.hpp"
#include "view/Page/LoginPage.hpp"


App::App(QObject * parent) : QObject(parent) {
	init();
}

//-----------------------------------------------------------
//		Initializations
//-----------------------------------------------------------

void App::init() {
// Core
	mCoreModel = QSharedPointer<CoreModel>::create("", this);
	mCoreModel->start();
// QML
	mEngine = new QQmlApplicationEngine(this);
	mEngine->addImportPath(":/");
	
	initCppInterfaces();
	
	const QUrl url(u"qrc:/Linphone/view/App/Main.qml"_qs);
	QObject::connect(mEngine, &QQmlApplicationEngine::objectCreated,
					 this, [url](QObject *obj, const QUrl &objUrl) {
		if (!obj && url == objUrl)
			QCoreApplication::exit(-1);
	}, Qt::QueuedConnection);
	mEngine->load(url);
}

void App::initCppInterfaces() {
	qmlRegisterSingletonType<LoginPage>(Constants::MainQmlUri, 1, 0, "LoginPageCpp", [](QQmlEngine *engine, QJSEngine *) -> QObject *{
		return new LoginPage(engine);
	});
}