#include <qloggingcategory.h>

#ifdef _WIN32
#include <Windows.h>
FILE *gStream = NULL;
#include <objbase.h>     // StringFromCLSID, CoTaskMemFree
#include <propkey.h>     // PKEY_AppUserModel_ID, PKEY_AppUserModel_ToastActivatorCLSID
#include <propvarutil.h> // InitPropVariantFromString, PropVariantClear
#include <shlguid.h>     // CLSID_ShellLink
#include <shobjidl.h>    // IShellLinkW, IPropertyStore
#endif

#include "core/App.hpp"
#include "core/logger/QtLogger.hpp"
#include "core/path/Paths.hpp"

#include "core/notifier/DesktopNotificationManagerCompat.hpp"
#include "core/notifier/NotificationActivator.hpp"

#include <QApplication>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QSurfaceFormat>
#include <QTranslator>

#ifdef QT_QML_DEBUG
#include <QQmlDebuggingEnabler>
#include <QStandardPaths>
#endif

#define WIDEN2(x) L##x
#define WIDEN(x) WIDEN2(x)

static const wchar_t *mAumid = WIDEN(APPLICATION_ID);

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

	// auto hrCom = RoInitialize(RO_INIT_MULTITHREADED);
	// HRESULT hrCom = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
	// qInfo() << "CoInitializeEx result:" << Qt::hex << hrCom;

	qInfo() << "Thread ID:" << GetCurrentThreadId();
	APTTYPE aptBefore;
	APTTYPEQUALIFIER qualBefore;
	CoGetApartmentType(&aptBefore, &qualBefore);
	qInfo() << "ApartmentType BEFORE CoInitializeEx:" << aptBefore;

	HRESULT hrCom = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
	qInfo() << "CoInitializeEx STA result:" << Qt::hex << hrCom;

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

	auto hr = DesktopNotificationManagerCompat::CreateStartMenuShortcut(mAumid, __uuidof(NotificationActivator));
	if (FAILED(hr)) {
		qWarning() << "CreateStartMenuShortcut failed:" << Qt::hex << hr;
	}

	//  Register AUMID and COM server (for a packaged app, this is a no-operation)
	hr = DesktopNotificationManagerCompat::RegisterAumidAndComServer(L"Linphone", __uuidof(NotificationActivator));
	if (FAILED(hr)) {
		qWarning() << "RegisterAumidAndComServer failed:" << Qt::hex << hr;
	}

	auto app = QSharedPointer<App>::create(argc, argv);

	hr = DesktopNotificationManagerCompat::RegisterActivator();
	if (FAILED(hr)) {
		qWarning() << "RegisterActivator failed:" << Qt::hex << hr;
	}

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
