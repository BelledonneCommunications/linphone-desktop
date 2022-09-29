/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifdef Q_OS_WIN
#include <QSettings>
#endif // ifdef Q_OS_WIN
#include <QCommandLineParser>
#include <QDir>
#include <QFileSelector>
#include <QLibraryInfo>
#include <QMenu>
#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSystemTrayIcon>
#include <QTimer>

#include "config.h"
#include "cli/Cli.hpp"
#include "components/Components.hpp"
#include "logger/Logger.hpp"
#include "paths/Paths.hpp"
#include "providers/AvatarProvider.hpp"
#include "providers/ImageProvider.hpp"
#include "providers/ExternalImageProvider.hpp"
#include "providers/QRCodeProvider.hpp"
#include "providers/ThumbnailProvider.hpp"
#include "translator/DefaultTranslator.hpp"
#include "utils/Utils.hpp"
#include "utils/Constants.hpp"
#include "components/other/desktop-tools/DesktopTools.hpp"

#include "components/timeline/TimelineModel.hpp"
#include "components/timeline/TimelineListModel.hpp"
#include "components/timeline/TimelineProxyModel.hpp"

#include "components/participant/ParticipantModel.hpp"
#include "components/participant/ParticipantListModel.hpp"
#include "components/participant/ParticipantProxyModel.hpp"

// =============================================================================

using namespace std;

namespace {
#ifdef Q_OS_LINUX
const QString AutoStartDirectory(QDir::homePath().append(QStringLiteral("/.config/autostart/")));
#elif defined(Q_OS_MACOS)
const QString OsascriptExecutable(QStringLiteral("osascript"));
#else
const QString AutoStartSettingsFilePath(
		QStringLiteral("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run")
		);
#endif // ifdef Q_OS_LINUX
}

// -----------------------------------------------------------------------------

#ifdef Q_OS_LINUX
static inline bool autoStartEnabled () {
	return QDir(AutoStartDirectory).exists() && QFile(AutoStartDirectory + EXECUTABLE_NAME ".desktop").exists();
}
#elif defined(Q_OS_MACOS)
static inline QString getMacOsBundlePath () {
	QDir dir(QCoreApplication::applicationDirPath());
	if (dir.dirName() != QLatin1String("MacOS"))
		return QString();
	
	dir.cdUp();
	dir.cdUp();
	
	QString path(dir.path());
	if (path.length() > 0 && path.right(1) == "/")
		path.chop(1);
	return path;
}

static inline QString getMacOsBundleName () {
	return QFileInfo(getMacOsBundlePath()).baseName();
}

static inline bool autoStartEnabled () {
	const QByteArray expectedWord(getMacOsBundleName().toUtf8());
	if (expectedWord.isEmpty()) {
		qInfo() << QStringLiteral("Application is not installed. Autostart unavailable.");
		return false;
	}
	
	QProcess process;
	process.start(OsascriptExecutable, { "-e", "tell application \"System Events\" to get the name of every login item" });
	if (!process.waitForFinished()) {
		qWarning() << QStringLiteral("Unable to execute properly: `%1` (%2).").arg(OsascriptExecutable).arg(process.errorString());
		return false;
	}
	
	// TODO: Move in utils?
	const QByteArray buf(process.readAll());
	for (const char *p = buf.data(), *word = p, *end = p + buf.length(); p <= end; ++p) {
		switch (*p) {
			case ' ':
			case '\r':
			case '\n':
			case '\t':
			case '\0':
				if (word != p) {
					if (!strncmp(word, expectedWord, size_t(p - word)))
						return true;
					word = p + 1;
				}
			default:
				break;
		}
	}
	
	return false;
}
#else
static inline bool autoStartEnabled () {
	return QSettings(AutoStartSettingsFilePath, QSettings::NativeFormat).value(EXECUTABLE_NAME).isValid();
}
#endif // ifdef Q_OS_LINUX

// -----------------------------------------------------------------------------

static inline bool installLocale (App &app, QTranslator &translator, const QLocale &locale) {
	return translator.load(locale, Constants::LanguagePath) && app.installTranslator(&translator);
}

static inline string getConfigPathIfExists (const QCommandLineParser &parser) {
	QString filePath = parser.value("config");
	string configPath;
	if(!QUrl(filePath).isRelative()){
		configPath = Utils::appStringToCoreString(FileDownloader::synchronousDownload(filePath, Utils::coreStringToAppString(Paths::getConfigDirPath(false)), true));
	}
	if( configPath == "")
		configPath = Paths::getConfigFilePath(filePath, false);
	if( configPath == "" )
		configPath = Paths::getConfigFilePath("", false);
	return configPath;
}

bool App::setFetchConfig (QCommandLineParser *parser) {
	bool fetched = false;
	QString filePath = parser->value("fetch-config");
	if( !filePath.isEmpty()){
		if(QUrl(filePath).isRelative()){// this is a file path
			filePath = Utils::coreStringToAppString(Paths::getConfigFilePath(filePath, false));
			if(!filePath.isEmpty())
				filePath = "file://"+filePath;
		}
		if(!filePath.isEmpty()){
			auto instance = CoreManager::getInstance();
			if(instance){
				auto core = instance->getCore();
				if(core){
					filePath.replace('\\','/');
					if(core->setProvisioningUri(Utils::appStringToCoreString(filePath)) == 0){
						parser->process(cleanParserKeys(parser, QStringList("fetch-config")));// Remove this parameter from the parser
						fetched = true;
					}else
						fetched = false;
				}
			}
		}
		if(!fetched){
			qWarning() <<"Remote provisionning cannot be retrieved. Command have beend cleaned";
			createParser();
		}
	}
	return fetched;
}
// -----------------------------------------------------------------------------



App::App (int &argc, char *argv[]) : SingleApplication(argc, argv, true, Mode::User | Mode::ExcludeAppPath | Mode::ExcludeAppVersion) {
	
	connect(this, SIGNAL(applicationStateChanged(Qt::ApplicationState)), this, SLOT(stateChanged(Qt::ApplicationState)));
	
	setWindowIcon(QIcon(Constants::WindowIconPath));
	
	createParser();
	mParser->process(*this);
	
	// Initialize logger.
	shared_ptr<linphone::Config> config = Utils::getConfigIfExists (QString::fromStdString(getConfigPathIfExists(*mParser)));
	Logger::init(config);
	if (mParser->isSet("verbose"))
		Logger::getInstance()->setVerbose(true);
	
	// List available locales.
	for (const auto &locale : QDir(Constants::LanguagePath).entryList())
		mAvailableLocales << QLocale(locale);
	
	// Init locale.
	mTranslator = new DefaultTranslator(this);
	mDefaultTranslator = new DefaultTranslator(this);
	initLocale(config);
	
	if (mParser->isSet("help")) {
		mParser->showHelp();
	}
	
	if (mParser->isSet("cli-help")) {
		Cli::showHelp();
		::exit(EXIT_SUCCESS);
	}
	
	if (mParser->isSet("version"))
		mParser->showVersion();
	
	mAutoStart = autoStartEnabled();
	
	qInfo() << QStringLiteral("Starting " APPLICATION_NAME " (bin: " EXECUTABLE_NAME ")");
	qInfo() << QStringLiteral("Use locale: %1").arg(mLocale);
}

App::~App () {
	qInfo() << QStringLiteral("Destroying app...");
}

void App::stop(){
	qInfo() << QStringLiteral("Stopping app...");
	if( mEngine ){
		delete mEngine;
		processEvents(QEventLoop::AllEvents);
	}
	CoreManager::uninit();
	processEvents(QEventLoop::AllEvents);	// Process all needed events on engine deletion.
	if( mParser)
		delete mParser;
}
// -----------------------------------------------------------------------------

QStringList App::cleanParserKeys(QCommandLineParser * parser, QStringList keys){
	QStringList oldArguments = parser->optionNames();
	QStringList parameters;
	parameters << "dummy";
	for(int i = 0 ; i < oldArguments.size() ; ++i){
		if( !keys.contains(oldArguments[i])){
			if( mParser->value(oldArguments[i]).isEmpty())
				parameters << "--"+oldArguments[i];
			else
				parameters << "--"+oldArguments[i]+"="+parser->value(oldArguments[i]);
		}
	}
	return parameters;
}

void App::processArguments(QHash<QString,QString> args){
	QList<QString> keys = args.keys();
	QStringList parameters = cleanParserKeys(mParser, keys);
	for(auto i = keys.begin() ; i != keys.end() ; ++i){
		parameters << "--"+(*i)+"="+args.value(*i);
	}
	if(!mParser->parse(parameters))
		qWarning() << "Parsing error : " << mParser->errorText();
}

static QQuickWindow *createSubWindow (QQmlApplicationEngine *engine, const char *path) {
	qInfo() << QStringLiteral("Creating subwindow: `%1`.").arg(path);
	
	QQmlComponent component(engine, QUrl(path));
	if (component.isError()) {
		qWarning() << component.errors();
		abort();
	}
	qInfo() << QStringLiteral("Subwindow status: `%1`.").arg(component.status());
	
	QObject *object = component.create();
	Q_ASSERT(object);
	
	QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
	object->setParent(engine);
	
	return qobject_cast<QQuickWindow *>(object);
}

// -----------------------------------------------------------------------------

void App::initContentApp () {
	std::string configPath;
	shared_ptr<linphone::Config> config;
	bool mustBeIconified = false;
	bool needRestart = true;
	
	// Destroy qml components and linphone core if necessary.
	if (mEngine) {
		needRestart = false;
		setFetchConfig(mParser);
		setOpened(false);
		qInfo() << QStringLiteral("Restarting app...");
		
		delete mEngine;
		
		mNotifier = nullptr;
		//
		CoreManager::uninit();
		removeTranslator(mTranslator);
		removeTranslator(mDefaultTranslator);
		delete mTranslator;
		delete mDefaultTranslator;
		mTranslator = new DefaultTranslator(this);
		mDefaultTranslator = new DefaultTranslator(this);
		configPath = getConfigPathIfExists(*mParser);
		config = Utils::getConfigIfExists (QString::fromStdString(configPath));
		initLocale(config);
	} else {
		configPath = getConfigPathIfExists(*mParser);
		config = Utils::getConfigIfExists(QString::fromStdString(configPath));
		// Update and download codecs.
		VideoCodecsModel::updateCodecs();
		VideoCodecsModel::downloadUpdatableCodecs(this);
		
		// Don't quit if last window is closed!!!
		setQuitOnLastWindowClosed(false);
		
		// Deal with received messages and CLI.
		QObject::connect(this, &App::receivedMessage, this, [](int, const QByteArray &byteArray) {
			QString command(byteArray);
			qInfo() << QStringLiteral("Received command from other application: `%1`.").arg(command);
			Cli::executeCommand(command);
		});
		
#ifndef Q_OS_MACOS
		mustBeIconified = mParser->isSet("iconified");
#endif // ifndef Q_OS_MACOS
		mColorListModel = new ColorListModel();
		mImageListModel = new ImageListModel();
	}
	
	// Change colors if necessary.
	mColorListModel->useConfig(config);
	mImageListModel->useConfig(config);
// There is no more database for callback. Setting it in the configuration before starting the core will do migration.
// When the migration is done by SDK, further migrations on call logs will do nothing. It is safe to use .
	config->setString("storage", "call_logs_db_uri", Paths::getCallHistoryFilePath());
	
	// Init core.
	CoreManager::init(this, Utils::coreStringToAppString(configPath));
	
	
	// Init engine content.
	mEngine = new QQmlApplicationEngine(this);
	
	// Provide `+custom` folders for custom components and `5.9` for old components.
	{
		QStringList selectors("custom");
		const QVersionNumber &version = QLibraryInfo::version();
		if (version.majorVersion() == 5 && version.minorVersion() == 9)
			selectors.push_back("5.9");
		(new QQmlFileSelector(mEngine, mEngine))->setExtraSelectors(selectors);
	}
	qInfo() << QStringLiteral("Activated selectors:") << QQmlFileSelector::get(mEngine)->selector()->allSelectors();
	
	// Set modules paths.
	mEngine->addImportPath(":/ui/modules");
	mEngine->addImportPath(":/ui/scripts");
	mEngine->addImportPath(":/ui/views");
	
	// Provide avatars/thumbnails providers.
	mEngine->addImageProvider(AvatarProvider::ProviderId, new AvatarProvider());
	mEngine->addImageProvider(ImageProvider::ProviderId, new ImageProvider());
	mEngine->addImageProvider(ExternalImageProvider::ProviderId, new ExternalImageProvider());
	mEngine->addImageProvider(QRCodeProvider::ProviderId, new QRCodeProvider());
	mEngine->addImageProvider(ThumbnailProvider::ProviderId, new ThumbnailProvider());
	
	mEngine->rootContext()->setContextProperty("applicationName", APPLICATION_NAME);

#ifdef APPLICATION_URL
	mEngine->rootContext()->setContextProperty("applicationUrl", APPLICATION_URL);
#else
	mEngine->rootContext()->setContextProperty("applicationUrl", "");
#endif
	
#ifdef APPLICATION_VENDOR
	mEngine->rootContext()->setContextProperty("applicationVendor", APPLICATION_VENDOR);
#else
	mEngine->rootContext()->setContextProperty("applicationVendor", "");
#endif
#ifdef APPLICATION_LICENCE
	mEngine->rootContext()->setContextProperty("applicationLicence", APPLICATION_LICENCE);
#else
	mEngine->rootContext()->setContextProperty("applicationLicence", "");
#endif
	mEngine->rootContext()->setContextProperty("copyrightRangeDate", COPYRIGHT_RANGE_DATE);
	mEngine->rootContext()->setContextProperty("Colors", mColorListModel->getQmlData());
	mEngine->rootContext()->setContextProperty("Images", mImageListModel->getQmlData());
	
	mEngine->rootContext()->setContextProperty("qtIsNewer_5_15_0", QT_VERSION >= QT_VERSION_CHECK(5, 15, 0) );
	
	registerTypes();
	registerSharedTypes();
	registerToolTypes();
	registerSharedToolTypes();
	
	// Enable notifications.
	mNotifier = new Notifier(mEngine);
	// Load main view.
	qInfo() << QStringLiteral("Loading main view...");
	mEngine->load(QUrl(Constants::QmlViewMainWindow));
	if (mEngine->rootObjects().isEmpty())
		qFatal("Unable to open main window.");
	
	QObject::connect(
				CoreManager::getInstance(),
				&CoreManager::coreManagerInitialized, CoreManager::getInstance(),
				[this, mustBeIconified]() mutable {
		if(CoreManager::getInstance()->started())
			openAppAfterInit(mustBeIconified);
	}
	);
	
	// Execute command argument if needed.
	const QString commandArgument = getCommandArgument();
	if (!commandArgument.isEmpty()) {
		Cli::CommandFormat format;
		Cli::executeCommand(commandArgument, &format);
		if (format == Cli::UriFormat || format == Cli::UrlFormat )
			mustBeIconified = true;
	}
}

// -----------------------------------------------------------------------------

QString App::getCommandArgument () {
	const QStringList &arguments = mParser->positionalArguments();
	return arguments.empty() ? QString("") : arguments[0];
}

// -----------------------------------------------------------------------------

#ifdef Q_OS_MACOS

bool App::event (QEvent *event) {
	if (event->type() == QEvent::FileOpen) {
		const QString url = static_cast<QFileOpenEvent *>(event)->url().toString();
		if (isSecondary()) {
			sendMessage(url.toLocal8Bit(), -1);
			::exit(EXIT_SUCCESS);
		}
		
		Cli::executeCommand(url);
	}else if(event->type() == QEvent::ApplicationStateChange){
		auto state = static_cast<QApplicationStateChangeEvent*>(event);
		if( state->applicationState() == Qt::ApplicationActive)
			smartShowWindow(getMainWindow());
	}
	
	return SingleApplication::event(event);
}

#endif // ifdef Q_OS_MACOS

// -----------------------------------------------------------------------------

QQuickWindow *App::getCallsWindow () const {
	if (CoreManager::getInstance()->getCore()->getConfig()->getInt(
				SettingsModel::UiSection, "disable_calls_window", 0
				))
		return nullptr;
	
	return mCallsWindow;
}

QQuickWindow *App::getMainWindow () const {
	return qobject_cast<QQuickWindow *>(
				const_cast<QQmlApplicationEngine *>(mEngine)->rootObjects().at(0)
				);
}

QQuickWindow *App::getSettingsWindow () const {
	return mSettingsWindow;
}

// -----------------------------------------------------------------------------

void App::smartShowWindow (QQuickWindow *window) {
	if (!window)
		return;
	window->setVisible(true);
	// Force show, maybe redundant with setVisible
	if(window->visibility() == QWindow::Maximized)// Avoid to change visibility mode
		window->showMaximized();
	else
		window->show();
	window->raise();// Raise ensure to get focus on Mac
	window->requestActivate();
}

// -----------------------------------------------------------------------------
bool App::hasFocus () const {
	return getMainWindow()->isActive() || (mCallsWindow && mCallsWindow->isActive());
}
void App::stateChanged(Qt::ApplicationState pState) {
	DesktopTools::applicationStateChanged(pState);
	auto core = CoreManager::getInstance();
	if(core)
		core->stateChanged(pState);
}
// -----------------------------------------------------------------------------

void App::createParser () {
	delete mParser;
	
	mParser = new QCommandLineParser();
	mParser->setApplicationDescription(tr("applicationDescription"));
	mParser->addPositionalArgument("command", tr("commandLineDescription").replace("%1", APPLICATION_NAME), "[command]");
	mParser->addOptions({
							{ { "h", "help" }, tr("commandLineOptionHelp") },
							{ "cli-help", tr("commandLineOptionCliHelp").replace("%1", APPLICATION_NAME) },
							{ { "v", "version" }, tr("commandLineOptionVersion") },
							{ "config", tr("commandLineOptionConfig").replace("%1", EXECUTABLE_NAME), tr("commandLineOptionConfigArg") },
							{ "fetch-config", tr("commandLineOptionFetchConfig").replace("%1", EXECUTABLE_NAME), tr("commandLineOptionFetchConfigArg") },
							{ { "c", "call" }, tr("commandLineOptionCall").replace("%1", EXECUTABLE_NAME),tr("commandLineOptionCallArg") },
						#ifndef Q_OS_MACOS
							{ "iconified", tr("commandLineOptionIconified") },
						#endif // ifndef Q_OS_MACOS
							{ { "V", "verbose" }, tr("commandLineOptionVerbose") }
						});
}

// -----------------------------------------------------------------------------

template<typename T, T *(*function)()>
static QObject *makeSharedSingleton (QQmlEngine *, QJSEngine *) {
	QObject *object = (*function)();
	QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
	return object;
}

template<typename T, T *(*function)(void)>
static inline void registerSharedSingletonType (const char *name) {
	qmlRegisterSingletonType<T>(Constants::MainQmlUri, 1, 0, name, makeSharedSingleton<T, function>);
}

template<typename T, T *(CoreManager::*function)()>
static QObject *makeSharedSingleton (QQmlEngine *, QJSEngine *) {
	QObject *object = (CoreManager::getInstance()->*function)();
	QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
	return object;
}


template<typename T, T *(CoreManager::*function)() const>
static QObject *makeSharedSingleton (QQmlEngine *, QJSEngine *) {
	QObject *object = (CoreManager::getInstance()->*function)();
	QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
	return object;
}

template<typename T, T *(CoreManager::*function)() const>
static inline void registerSharedSingletonType (const char *name) {
	qmlRegisterSingletonType<T>(Constants::MainQmlUri, 1, 0, name, makeSharedSingleton<T, function>);
}

template<typename T, T *(CoreManager::*function)()>
static inline void registerSharedSingletonType (const char *name) {
	qmlRegisterSingletonType<T>(Constants::MainQmlUri, 1, 0, name, makeSharedSingleton<T, function>);
}

template<typename T>
static inline void registerUncreatableType (const char *name) {
	qmlRegisterUncreatableType<T>(Constants::MainQmlUri, 1, 0, name, QLatin1String("Uncreatable"));
}

template<typename T>
static inline void registerSingletonType (const char *name) {
	qmlRegisterSingletonType<T>(Constants::MainQmlUri, 1, 0, name, [](QQmlEngine *engine, QJSEngine *) -> QObject *{
		return new T(engine);
	});
}

template<typename T>
static inline void registerType (const char *name) {
	qmlRegisterType<T>(Constants::MainQmlUri, 1, 0, name);
}

template<typename T>
static inline void registerToolType (const char *name) {
	qmlRegisterSingletonType<T>(name, 1, 0, name, [](QQmlEngine *engine, QJSEngine *) -> QObject *{
		return new T(engine);
	});
}

template<typename T, typename Owner, T *(Owner::*function)() const>
static QObject *makeSharedTool (QQmlEngine *, QJSEngine *) {
	QObject *object = (Owner::getInstance()->*function)();
	QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
	return object;
}

template<typename T, typename Owner, T *(Owner::*function)() const>
static inline void registerSharedToolType (const char *name) {
	qmlRegisterSingletonType<T>(name, 1, 0, name, makeSharedTool<T, Owner, function>);
}

void App::registerTypes () {
	qInfo() << QStringLiteral("Registering types...");
	
	qRegisterMetaType<shared_ptr<linphone::Account>>();
	qRegisterMetaType<ChatRoomModel::EntryType>();
	qRegisterMetaType<shared_ptr<linphone::SearchResult>>();
	qRegisterMetaType<std::list<std::shared_ptr<linphone::SearchResult> > >();
	qRegisterMetaType<QSharedPointer<ChatMessageModel>>();
	qRegisterMetaType<QSharedPointer<ChatRoomModel>>();
	qRegisterMetaType<QSharedPointer<ParticipantListModel>>();
	qRegisterMetaType<QSharedPointer<ParticipantDeviceModel>>();
	qRegisterMetaType<QSharedPointer<ChatMessageModel>>();
	qRegisterMetaType<QSharedPointer<ChatNoticeModel>>();
	qRegisterMetaType<QSharedPointer<ChatCallModel>>();
	qRegisterMetaType<QSharedPointer<ConferenceInfoModel>>();
	//qRegisterMetaType<std::shared_ptr<ChatEvent>>();
	LinphoneEnums::registerMetaTypes();
	
	registerType<AssistantModel>("AssistantModel");
	registerType<AuthenticationNotifier>("AuthenticationNotifier");
	registerType<CallsListProxyModel>("CallsListProxyModel");
	registerType<Camera>("Camera");
	registerType<ChatRoomProxyModel>("ChatRoomProxyModel");
	registerType<ConferenceHelperModel>("ConferenceHelperModel");
	registerType<ConferenceProxyModel>("ConferenceProxyModel");
	registerType<ConferenceInfoModel>("ConferenceInfoModel");
	registerType<ConferenceInfoProxyModel>("ConferenceInfoProxyModel");
	registerType<ContactsListProxyModel>("ContactsListProxyModel");
	registerType<ContactsImporterListProxyModel>("ContactsImporterListProxyModel");
	registerType<ContentProxyModel>("ContentProxyModel");
	registerType<FileDownloader>("FileDownloader");
	registerType<FileExtractor>("FileExtractor");
	registerType<HistoryProxyModel>("HistoryProxyModel");
	registerType<LdapProxyModel>("LdapProxyModel");
	registerType<ParticipantImdnStateProxyModel>("ParticipantImdnStateProxyModel");
	registerType<SipAddressesProxyModel>("SipAddressesProxyModel");
	registerType<SearchSipAddressesModel>("SearchSipAddressesModel");
	registerType<SearchSipAddressesProxyModel>("SearchSipAddressesProxyModel");
	registerType<TimeZoneProxyModel>("TimeZoneProxyModel");
	
	registerType<ColorProxyModel>("ColorProxyModel");
	registerType<ImageColorsProxyModel>("ImageColorsProxyModel");
	registerType<ImageProxyModel>("ImageProxyModel");
	registerType<TimelineProxyModel>("TimelineProxyModel");
	registerType<ParticipantProxyModel>("ParticipantProxyModel");
	registerType<ParticipantDeviceProxyModel>("ParticipantDeviceProxyModel");
	registerType<SoundPlayer>("SoundPlayer");
	registerType<TelephoneNumbersModel>("TelephoneNumbersModel");
	
	registerSingletonType<AudioCodecsModel>("AudioCodecsModel");
	registerSingletonType<OwnPresenceModel>("OwnPresenceModel");
	registerSingletonType<Presence>("Presence");
	//registerSingletonType<TimelineModel>("TimelineModel");
	registerSingletonType<UrlHandlers>("UrlHandlers");
	registerSingletonType<VideoCodecsModel>("VideoCodecsModel");
	
	
	registerUncreatableType<CallModel>("CallModel");
	registerUncreatableType<ChatCallModel>("ChatCallModel");
	registerUncreatableType<ChatMessageModel>("ChatMessageModel");
	registerUncreatableType<ChatNoticeModel>("ChatNoticeModel");
	registerUncreatableType<ChatRoomModel>("ChatRoomModel");
	registerUncreatableType<ColorModel>("ColorModel");
	registerUncreatableType<ImageModel>("ImageModel");
	registerUncreatableType<ConferenceHelperModel::ConferenceAddModel>("ConferenceAddModel");
	registerUncreatableType<ConferenceModel>("ConferenceModel");
	registerUncreatableType<ContactModel>("ContactModel");
	registerUncreatableType<ContactsImporterModel>("ContactsImporterModel");
	registerUncreatableType<ContentModel>("ContentModel");
	registerUncreatableType<ContentListModel>("ContentListModel");
	registerUncreatableType<HistoryModel>("HistoryModel");
	registerUncreatableType<LdapModel>("LdapModel");
	registerUncreatableType<RecorderModel>("RecorderModel");
	registerUncreatableType<SearchResultModel>("SearchResultModel");
	registerUncreatableType<SipAddressObserver>("SipAddressObserver");	
	registerUncreatableType<VcardModel>("VcardModel");
	registerUncreatableType<TimelineModel>("TimelineModel");
	registerUncreatableType<TunnelModel>("TunnelModel");
	registerUncreatableType<TunnelConfigModel>("TunnelConfigModel");
	registerUncreatableType<TunnelConfigProxyModel>("TunnelConfigProxyModel");
	registerUncreatableType<ParticipantModel>("ParticipantModel");
	registerUncreatableType<ParticipantListModel>("ParticipantListModel");
	registerUncreatableType<ParticipantDeviceModel>("ParticipantDeviceModel");
	registerUncreatableType<ParticipantDeviceListModel>("ParticipantDeviceListModel");
	registerUncreatableType<ParticipantImdnStateModel>("ParticipantImdnStateModel");
	registerUncreatableType<ParticipantImdnStateListModel>("ParticipantImdnStateListModel");
	
	
	
	qmlRegisterUncreatableMetaObject(LinphoneEnums::staticMetaObject, "LinphoneEnums", 1, 0, "LinphoneEnums", "Only enums");
}

void App::registerSharedTypes () {
	qInfo() << QStringLiteral("Registering shared types...");
	
	registerSharedSingletonType<App, &App::getInstance>("App");
	registerSharedSingletonType<CoreManager, &CoreManager::getInstance>("CoreManager");
	registerSharedSingletonType<SettingsModel, &CoreManager::getSettingsModel>("SettingsModel");
	registerSharedSingletonType<AccountSettingsModel, &CoreManager::getAccountSettingsModel>("AccountSettingsModel");
	registerSharedSingletonType<SipAddressesModel, &CoreManager::getSipAddressesModel>("SipAddressesModel");  
	registerSharedSingletonType<CallsListModel, &CoreManager::getCallsListModel>("CallsListModel");
	registerSharedSingletonType<ContactsListModel, &CoreManager::getContactsListModel>("ContactsListModel");
	registerSharedSingletonType<ContactsImporterListModel, &CoreManager::getContactsImporterListModel>("ContactsImporterListModel");
	registerSharedSingletonType<LdapListModel, &CoreManager::getLdapListModel>("LdapListModel");
	registerSharedSingletonType<TimelineListModel, &CoreManager::getTimelineListModel>("TimelineListModel");
	registerSharedSingletonType<RecorderManager, &CoreManager::getRecorderManager>("RecorderManager");
	
	//qmlRegisterSingletonType<ColorListModel>(Constants::MainQmlUri, 1, 0, "ColorList", mColorListModel);
	
	//registerSharedSingletonType<ColorListModel, &App::getColorListModel>("ColorCpp");
}

void App::registerToolTypes () {
	qInfo() << QStringLiteral("Registering tool types...");
	
	registerToolType<Clipboard>("Clipboard");
	registerToolType<DesktopTools>("DesktopTools");
	registerToolType<TextToSpeech>("TextToSpeech");
	registerToolType<Units>("Units");
	registerToolType<ContactsImporterPluginsManager>("ContactsImporterPluginsManager");
	registerToolType<Utils>("UtilsCpp");
	registerToolType<Constants>("ConstantsCpp");
}

void App::registerSharedToolTypes () {
	qInfo() << QStringLiteral("Registering shared tool types...");
	
	registerSharedToolType<ColorListModel,App,  &App::getColorListModel>("ColorsList");
}

// -----------------------------------------------------------------------------

void App::setTrayIcon () {
	QQuickWindow *root = getMainWindow();
	QSystemTrayIcon* systemTrayIcon = (mSystemTrayIcon?mSystemTrayIcon : new QSystemTrayIcon(nullptr));// Workaround : QSystemTrayIcon cannot be deleted because of setContextMenu (indirectly)
		
	// trayIcon: Right click actions.
	QAction *settingsAction = new QAction(tr("settings"), root);
	root->connect(settingsAction, &QAction::triggered, root, [this] {
		App::smartShowWindow(getSettingsWindow());
	});
	
	QAction *updateCheckAction = new QAction(tr("checkForUpdates"), root);
	root->connect(updateCheckAction, &QAction::triggered, root, [this] {
		checkForUpdates(true);
	});
	
	QAction *aboutAction = new QAction(tr("about"), root);
	root->connect(aboutAction, &QAction::triggered, root, [root] {
		App::smartShowWindow(root);
		QMetaObject::invokeMethod(
					root, Constants::AttachVirtualWindowMethodName, Qt::DirectConnection,
					Q_ARG(QVariant, QUrl(Constants::AboutPath)), Q_ARG(QVariant, QVariant()), Q_ARG(QVariant, QVariant())
					);
	});
	
	QAction *restoreAction = new QAction(tr("restore"), root);
	root->connect(restoreAction, &QAction::triggered, root, [root] {
		smartShowWindow(root);
	});
	
	QAction *quitAction = new QAction(tr("quit"), root);
	root->connect(quitAction, &QAction::triggered, this, &App::quit);
	
	// trayIcon: Left click actions.
	static QMenu *menu = new QMenu();// Static : Workaround about a bug with setContextMenu where it cannot be called more than once.
	root->connect(systemTrayIcon, &QSystemTrayIcon::activated, [root](
				  QSystemTrayIcon::ActivationReason reason
				  ) {
		if (reason == QSystemTrayIcon::Trigger) {
			if (root->visibility() == QWindow::Hidden)
				smartShowWindow(root);
			else
				root->hide();
		}
	});
	menu->setTitle(APPLICATION_NAME);
	// Build trayIcon menu.
	menu->addAction(settingsAction);
	menu->addAction(updateCheckAction);
	menu->addAction(aboutAction);
	menu->addSeparator();
	menu->addAction(restoreAction);
	menu->addSeparator();
	menu->addAction(quitAction);
	if(!mSystemTrayIcon)
		systemTrayIcon->setContextMenu(menu);// This is a Qt bug. We cannot call setContextMenu more than once. So we have to keep an instance of the menu.
	systemTrayIcon->setIcon(QIcon(Constants::WindowIconPath));
	systemTrayIcon->setToolTip(APPLICATION_NAME);
	systemTrayIcon->show();
	if(!mSystemTrayIcon)
		mSystemTrayIcon = systemTrayIcon;
	if(!QSystemTrayIcon::isSystemTrayAvailable())
		qInfo() << "System tray is not available";
}

// -----------------------------------------------------------------------------

void App::initLocale (const shared_ptr<linphone::Config> &config) {
	// Try to use preferred locale.
	QString locale;
	
	// Use english. This default translator is used if there are no found translations in others loads
	mLocale = Constants::DefaultLocale;
	if (!installLocale(*this, *mDefaultTranslator, QLocale(mLocale)))
		qFatal("Unable to install default translator.");
	
	if (config)
		locale = Utils::coreStringToAppString(config->getString(SettingsModel::UiSection, "locale", ""));
	
	if (!locale.isEmpty() && installLocale(*this, *mTranslator, QLocale(locale))) {
		mLocale = locale;
		return;
	}
	
	// Try to use system locale.
	QLocale sysLocale = QLocale::system();
	if (installLocale(*this, *mTranslator, sysLocale)) {
		mLocale = sysLocale.name();
		return;
	}
	
}

QString App::getConfigLocale () const {
	return Utils::coreStringToAppString(
				CoreManager::getInstance()->getCore()->getConfig()->getString(
					SettingsModel::UiSection, "locale", ""
    )
				);
}

void App::setConfigLocale (const QString &locale) {
	CoreManager::getInstance()->getCore()->getConfig()->setString(
				SettingsModel::UiSection, "locale", Utils::appStringToCoreString(locale)
				);
	
	emit configLocaleChanged(locale);
}

QString App::getLocale () const {
	return mLocale;
}

// -----------------------------------------------------------------------------

#ifdef Q_OS_LINUX

void App::setAutoStart (bool enabled) {
	if (enabled == mAutoStart)
		return;
	
	QDir dir(AutoStartDirectory);
	if (!dir.exists() && !dir.mkpath(AutoStartDirectory)) {
		qWarning() << QStringLiteral("Unable to build autostart dir path: `%1`.").arg(AutoStartDirectory);
		return;
	}
	
	const QString confPath(AutoStartDirectory + EXECUTABLE_NAME ".desktop");
	qInfo() << QStringLiteral("Updating `%1`...").arg(confPath);
	QFile file(confPath);
	
	if (!enabled) {
		if (file.exists() && !file.remove()) {
			qWarning() << QLatin1String("Unable to remove autostart file: `" EXECUTABLE_NAME ".desktop`.");
			return;
		}
		
		mAutoStart = enabled;
		emit autoStartChanged(enabled);
		return;
	}
	
	if (!file.open(QFile::WriteOnly)) {
		qWarning() << "Unable to open autostart file: `" EXECUTABLE_NAME ".desktop`.";
		return;
	}
	
	const QString binPath(applicationFilePath());
	
	// Check if installation is done via Flatpak, AppImage, or classic package
	// in order to rewrite a correct exec path for autostart
	QString exec;
	qDebug() << "binpath=" << binPath;
	if (binPath.startsWith("/app")) { //Flatpak
		exec = QStringLiteral("flatpak run " APPLICATION_ID);
		qDebug() << "exec path autostart set flatpak=" << exec;
	}
	else if (binPath.startsWith("/tmp/.mount")) { //Appimage
		exec = QProcessEnvironment::systemEnvironment().value(QStringLiteral("APPIMAGE"));
		qDebug() << "exec path autostart set appimage=" << exec;
	}
	else { //classic package
		exec = binPath;
		qDebug() << "exec path autostart set classic package=" << exec;
	}
	
	QTextStream(&file) << QString(
							  "[Desktop Entry]\n"
    "Name=" APPLICATION_NAME "\n"
    "GenericName=SIP Phone\n"
    "Comment=" APPLICATION_DESCRIPTION "\n"
    "Type=Application\n"
    "Exec=" + exec + " --iconified\n"
    "Terminal=false\n"
    "Categories=Network;Telephony;\n"
    "MimeType=x-scheme-handler/sip-" EXECUTABLE_NAME ";x-scheme-handler/sip;x-scheme-handler/sips-" EXECUTABLE_NAME ";x-scheme-handler/sips;x-scheme-handler/tel;x-scheme-handler/callto;\n"
  );
	
	mAutoStart = enabled;
	emit autoStartChanged(enabled);
}

#elif defined(Q_OS_MACOS)

void App::setAutoStart (bool enabled) {
	if (enabled == mAutoStart)
		return;
	
	if (getMacOsBundlePath().isEmpty()) {
		qWarning() << QStringLiteral("Application is not installed. Unable to change autostart state.");
		return;
	}
	
	if (enabled)
		QProcess::execute(OsascriptExecutable, {
							  "-e", "tell application \"System Events\" to make login item at end with properties"
							  "{ path: \"" + getMacOsBundlePath() + "\", hidden: false }"
						  });
	else
		QProcess::execute(OsascriptExecutable, {
							  "-e", "tell application \"System Events\" to delete login item \"" + getMacOsBundleName() + "\""
						  });
	
	mAutoStart = enabled;
	emit autoStartChanged(enabled);
}

#else

void App::setAutoStart (bool enabled) {
	if (enabled == mAutoStart)
		return;
	
	QSettings settings(AutoStartSettingsFilePath, QSettings::NativeFormat);
	if (enabled)
		settings.setValue(EXECUTABLE_NAME, QDir::toNativeSeparators(applicationFilePath()));
	else
		settings.remove(EXECUTABLE_NAME);
	
	mAutoStart = enabled;
	emit autoStartChanged(enabled);
}

#endif // ifdef Q_OS_LINUX

// -----------------------------------------------------------------------------

void App::openAppAfterInit (bool mustBeIconified) {
	qInfo() << QStringLiteral("Open " APPLICATION_NAME " app.");
	auto coreManager = CoreManager::getInstance();
	coreManager->getSettingsModel()->updateCameraMode();
	// Create other windows.
	mCallsWindow = createSubWindow(mEngine, Constants::QmlViewCallsWindow);
	mSettingsWindow = createSubWindow(mEngine, Constants::QmlViewSettingsWindow);
	QObject::connect(mSettingsWindow, &QWindow::visibilityChanged, this, [coreManager](QWindow::Visibility visibility) {
		if (visibility == QWindow::Hidden) {
			qInfo() << QStringLiteral("Update nat policy.");
			shared_ptr<linphone::Core> core = coreManager->getCore();
			core->setNatPolicy(core->getNatPolicy());
		}
	});
	
	QQuickWindow *mainWindow = getMainWindow();
	
#ifndef __APPLE__
	// Enable TrayIconSystem.
	if (!QSystemTrayIcon::isSystemTrayAvailable())
		qWarning("System tray not found on this system.");
	else
		setTrayIcon();
#endif // ifndef __APPLE__
	
	// Display Assistant if it does not exist proxy config.
	if (coreManager->getAccountList().empty())
		QMetaObject::invokeMethod(mainWindow, "setView", Q_ARG(QVariant, Constants::AssistantViewName), Q_ARG(QVariant, QString("")), Q_ARG(QVariant, QString("")));
	
#ifdef ENABLE_UPDATE_CHECK
	QTimer *timer = new QTimer(mEngine);
	timer->setInterval(Constants::VersionUpdateCheckInterval);
	
	QObject::connect(timer, &QTimer::timeout, this, &App::checkForUpdate);
	timer->start();
	
	checkForUpdates();
#endif // ifdef ENABLE_UPDATE_CHECK
	
	if(setFetchConfig(mParser))
		restart();
	else{
		// Launch call if wanted and clean parser
		if( mParser->isSet("call") && coreManager->isLastRemoteProvisioningGood()){
			QString sipAddress = mParser->value("call");
			mParser->parse(cleanParserKeys(mParser, QStringList("call")));// Clean call from parser
			if(coreManager->started()){
				coreManager->getCallsListModel()->launchAudioCall(sipAddress);
			}else{
				QObject * context = new QObject();
				QObject::connect(CoreManager::getInstance(), &CoreManager::coreManagerInitialized,context,
								 [sipAddress,coreManager, context]() mutable {
					if(context){
						delete context;
						context = nullptr;
						coreManager->getCallsListModel()->launchAudioCall(sipAddress);
					}
				});
			}
		}
#ifndef __APPLE__
		if (!mustBeIconified)
			smartShowWindow(mainWindow);
#else
		Q_UNUSED(mustBeIconified);
		smartShowWindow(mainWindow);
#endif
		setOpened(true);
	}
}

// -----------------------------------------------------------------------------
QString App::getStrippedApplicationVersion(){// x.y.z but if 'z-*' then x.y.z-1
	QString currentVersion = applicationVersion();
	QStringList versions = currentVersion.split('.');
	if(versions.size() >=3){
		currentVersion = versions[0]+"."+versions[1]+".";
		QStringList patchVersions = versions[2].split('-');
		if( patchVersions.size() > 1 ) {
			bool ok;
			patchVersions[1].toInt(&ok);
			if( !ok)	// Second part of patch is not a number (ie: alpha, beta, pre). Reduce version.
				currentVersion += QString::number(patchVersions[0].toInt()-1);
			else
				currentVersion += patchVersions[0];
		} else
			currentVersion += patchVersions[0];
	}
	return currentVersion;
}
void App::checkForUpdate() {
	checkForUpdates(false);
}
void App::checkForUpdates(bool force) {
	if(force || CoreManager::getInstance()->getSettingsModel()->isCheckForUpdateEnabled())
		CoreManager::getInstance()->getCore()->checkForUpdate(
					Utils::appStringToCoreString(applicationVersion())
					);
}
