#include <QApplication>
#include <QQmlApplicationEngine>

#include "core/App.hpp"
#include "core/logger/QtLogger.hpp"
#include "core/path/Paths.hpp"

#include <QLocale>
#include <QSurfaceFormat>
#include <QTranslator>
#include <iostream>
#include <qloggingcategory.h>
#ifdef QT_QML_DEBUG
#include <QQmlDebuggingEnabler>
#endif

#ifdef _WIN32
#include <Windows.h>
FILE *gStream = NULL;
#endif

#if QT_VERSION < QT_VERSION_CHECK(5, 15, 10)
// From 5.15.2 to 5.15.10, sometimes, Accessibility freeze the application : Deactivate handlers.
#define ACCESSBILITY_WORKAROUND
#include <QAccessible>
#include <QAccessibleEvent>

void DummyUpdateHandler(QAccessibleEvent *event) {
}
void DummyRootObjectHandler(QObject *) {
}
#endif



void cleanStream() {
#ifdef _WIN32
	if (gStream) {
		fflush(stdout);
		fflush(stderr);
		fclose(gStream);
	}
#endif
}

int main(int argc, char *argv[]) {

	/*
	#if defined _WIN32
	    // log in console only if launched from console
	    if (AttachConsole(ATTACH_PARENT_PROCESS)) {
	        freopen_s(&gStream, "CONOUT$", "w", stdout);
	        freopen_s(&gStream, "CONOUT$", "w", stderr);
	    }
	#endif
	*/

	// Useful to share camera on Fullscreen (other context) or multiscreens
	lDebug() << "[Main] Setting ShareOpenGLContexts";
	QApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
	lDebug() << "[Main] Disabling VSync";
	// Ignore vertical sync. This way, we avoid blinking on resizes(and other refresh like layouts etc.).
	auto ignoreVSync = QSurfaceFormat::defaultFormat();
	ignoreVSync.setSwapInterval(0);
	QSurfaceFormat::setDefaultFormat(ignoreVSync);
	// Disable QML cache. Avoid malformed cache.
	lDebug() << "[Main] Disabling QML disk cache";
	qputenv("QML_DISABLE_DISK_CACHE", "true");
	lDebug() << "[Main] Setting application to UTF8";
	setlocale(LC_CTYPE, ".UTF8");
	lDebug() << "[Main] Creating application";
	auto app = QSharedPointer<App>::create(argc, argv);

#ifdef ACCESSBILITY_WORKAROUND
	QAccessible::installUpdateHandler(DummyUpdateHandler);
	QAccessible::installRootObjectHandler(DummyRootObjectHandler);
#endif

	if (app->isSecondary()) {
		lDebug() << "[Main] Sending command from secondary application";
		app->sendCommand();
		qInfo() << QStringLiteral("[Main] Running secondary app success. Kill it now.");
		app->clean();
		cleanStream();
		return EXIT_SUCCESS;
	} else {
		lDebug() << "[Main] Initializing core for primary application";
		app->initCore();
		lDebug() << "[Main] Preparing application's connections";
		app->setSelf(app);
	}

	int result = 0;
	do {
		lDebug() << "[Main] Sending command from primary application";
		app->sendCommand();
		lInfo() << "[Main] Running application";
		result = app->exec();
	} while (result == (int)App::StatusCode::gRestartCode);
	QString message = "[Main] Exiting app with the code : " + QString::number(result);
	if (!result) lInfo() << message;
	else lWarning() << message;
	app->clean();
	app = nullptr;
	cleanStream();

	return result;
}
