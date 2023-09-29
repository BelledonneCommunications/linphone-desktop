#include "App.hpp"

#include <QCoreApplication>


App::App(QObject * parent) : QObject(parent) {
	init();
}


void App::init() {
// Core
	mCoreModel = QSharedPointer<CoreModel>::create("", this);
	mCoreModel->start();
// QML
	mEngine = new QQmlApplicationEngine(this);
	mEngine->addImportPath(":/");
	
	const QUrl url(u"qrc:/Linphone/view/qml/App/Main.qml"_qs);
	QObject::connect(mEngine, &QQmlApplicationEngine::objectCreated,
					 this, [url](QObject *obj, const QUrl &objUrl) {
		if (!obj && url == objUrl)
			QCoreApplication::exit(-1);
	}, Qt::QueuedConnection);
	mEngine->load(url);
}