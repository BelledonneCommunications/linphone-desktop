#include <QApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>
#include <qloggingcategory.h>

#include "core/App.hpp"

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
#if defined _WIN32
	// log in console only if launched from console
	if (AttachConsole(ATTACH_PARENT_PROCESS)) {
		freopen_s(&gStream, "CONOUT$", "w", stdout);
		freopen_s(&gStream, "CONOUT$", "w", stderr);
	}
#endif
	// Useful to share camera on Fullscreen (other context) or multiscreens
	QApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
	// Disable QML cache. Avoid malformed cache.
	qputenv("QML_DISABLE_DISK_CACHE", "true");
	setlocale(LC_CTYPE, ".UTF8");

	auto app = QSharedPointer<App>::create(argc, argv);

	QTranslator translator;
	const QStringList uiLanguages = QLocale::system().uiLanguages();
	for (const QString &locale : uiLanguages) {
		const QString baseName = "Linphone_" + QLocale(locale).name();
		if (translator.load(":/i18n/" + baseName)) {
			app->installTranslator(&translator);
			break;
		}
	}

#ifdef ACCESSBILITY_WORKAROUND
	QAccessible::installUpdateHandler(DummyUpdateHandler);
	QAccessible::installRootObjectHandler(DummyRootObjectHandler);
#endif

	if (app->isSecondary()) {
		app->sendCommand();
		qInfo() << QStringLiteral("Running secondary app success. Kill it now.");
		app->clean();
		cleanStream();
		return EXIT_SUCCESS;
	} else {
		app->initCore();
		app->setSelf(app);
	}

	int result = 0;
	do {
		app->sendCommand();
		result = app->exec();
	} while (result == (int)App::StatusCode::gRestartCode);
	qWarning() << "[Main] Exiting app with the code : " << result;
	app->clean();
	app = nullptr;

	return result;
}
