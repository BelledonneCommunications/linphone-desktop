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
#include <QMenu>
#include <QProcessEnvironment>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlFileSelector>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QSystemTrayIcon>
#include <QTimer>
#include <QTranslator>

#include "core/account/AccountCore.hpp"
#include "core/account/AccountDeviceGui.hpp"
#include "core/account/AccountDeviceProxy.hpp"
#include "core/address-books/carddav/CarddavGui.hpp"
#include "core/address-books/carddav/CarddavProxy.hpp"
#include "core/address-books/ldap/LdapGui.hpp"
#include "core/address-books/ldap/LdapProxy.hpp"
#include "core/call-history/CallHistoryProxy.hpp"
#include "core/call/CallCore.hpp"
#include "core/call/CallGui.hpp"
#include "core/call/CallList.hpp"
#include "core/call/CallProxy.hpp"
#include "core/camera/CameraGui.hpp"
#include "core/chat/ChatProxy.hpp"
#include "core/chat/files/ChatMessageFileProxy.hpp"
#include "core/chat/message/ChatMessageGui.hpp"
#include "core/chat/message/EventLogGui.hpp"
#include "core/chat/message/EventLogList.hpp"
#include "core/chat/message/EventLogProxy.hpp"
#include "core/chat/message/content/ChatMessageContentGui.hpp"
#include "core/chat/message/content/ChatMessageContentProxy.hpp"
#include "core/chat/message/imdn/ImdnStatusProxy.hpp"
#include "core/conference/ConferenceGui.hpp"
#include "core/conference/ConferenceInfoGui.hpp"
#include "core/conference/ConferenceInfoProxy.hpp"
#include "core/emoji/EmojiProxy.hpp"
#include "core/fps-counter/FPSCounter.hpp"
#include "core/friend/FriendCore.hpp"
#include "core/friend/FriendGui.hpp"
#include "core/logger/QtLogger.hpp"
#include "core/login/LoginPage.hpp"
#include "core/notifier/Notifier.hpp"
#include "core/participant/ParticipantDeviceProxy.hpp"
#include "core/participant/ParticipantGui.hpp"
#include "core/participant/ParticipantInfoProxy.hpp"
#include "core/participant/ParticipantProxy.hpp"
#include "core/payload-type/PayloadTypeCore.hpp"
#include "core/payload-type/PayloadTypeGui.hpp"
#include "core/payload-type/PayloadTypeProxy.hpp"
#include "core/phone-number/PhoneNumber.hpp"
#include "core/phone-number/PhoneNumberProxy.hpp"
#include "core/recorder/RecorderGui.hpp"
#include "core/register/RegisterPage.hpp"
#include "core/screen/ScreenList.hpp"
#include "core/screen/ScreenProxy.hpp"
#include "core/search/MagicSearchProxy.hpp"
#include "core/setting/SettingsCore.hpp"
#include "core/singleapplication/singleapplication.h"
#include "core/sound-player/SoundPlayerGui.hpp"
#include "core/timezone/TimeZoneProxy.hpp"
#include "core/translator/DefaultTranslatorCore.hpp"
#include "core/variant/VariantList.hpp"
#include "core/videoSource/VideoSourceDescriptorGui.hpp"
#include "model/friend/FriendsManager.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Constants.hpp"
#include "tool/EnumsToString.hpp"
#include "tool/Utils.hpp"
#include "tool/accessibility/AccessibilityHelper.hpp"
#include "tool/accessibility/FocusHelper.hpp"
#include "tool/accessibility/KeyboardShortcuts.hpp"
#ifdef HAVE_CRASH_HANDLER
#include "tool/crash_reporter/CrashReporter.hpp"
#endif
#include "tool/native/DesktopTools.hpp"
#include "tool/providers/AvatarProvider.hpp"
#include "tool/providers/EmojiProvider.hpp"
#include "tool/providers/ImageProvider.hpp"
#include "tool/providers/ScreenProvider.hpp"
#include "tool/providers/ThumbnailProvider.hpp"
#include "tool/request/CallbackHelper.hpp"
#include "tool/request/RequestDialog.hpp"
#include "tool/thread/Thread.hpp"
#include "tool/ui/DashRectangle.hpp"

#if defined(Q_OS_MACOS)
#include "core/event-count-notifier/EventCountNotifierMacOs.hpp"
#else
#include "core/event-count-notifier/EventCountNotifierSystemTrayIcon.hpp"
#endif // if defined(Q_OS_MACOS)

DEFINE_ABSTRACT_OBJECT(App)

#ifdef Q_OS_LINUX
const QString AutoStartDirectory(QDir::homePath().append(QStringLiteral("/.config/autostart/")));
const QString ApplicationsDirectory(QDir::homePath().append(QStringLiteral("/.local/share/applications/")));
const QString IconsDirectory(QDir::homePath().append(QStringLiteral("/.local/share/icons/hicolor/scalable/apps/")));
#elif defined(Q_OS_MACOS)
const QString OsascriptExecutable(QStringLiteral("osascript"));
#else
const QString
    AutoStartSettingsFilePath(QStringLiteral("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run"));
#endif

// -----------------------------------------------------------------------------
//		Autostart
// -----------------------------------------------------------------------------

#ifdef Q_OS_LINUX
bool App::autoStartEnabled() {
	const QString confPath(AutoStartDirectory + EXECUTABLE_NAME ".desktop");
	QFile file(confPath);
	if (!QDir(AutoStartDirectory).exists() || !file.exists()) return false;
	if (!file.open(QFile::ReadOnly)) {
		qWarning() << "Unable to open autostart file in read only: `" << confPath << "`.";
		return false;
	}

	// Check if installation is done via Flatpak, AppImage, or classic package
	// in order to check if there is a correct exec path for autostart

	QString exec = getApplicationPath();

	QTextStream in(&file);
	QString autoStartConf = in.readAll();

	int index = -1;
	// check if the Exec part of the autostart ini file not corresponding to our executable (old desktop entry with
	// wrong version in filename)
	if (autoStartConf.indexOf(QString("Exec=" + exec + " ")) <
	    0) { // On autostart, there is the option --minimized so there is one space.
		// replace file
		setAutoStart(true);
	}

	return true;
}
#elif defined(Q_OS_MACOS)
static inline QString getMacOsBundlePath() {
	QDir dir(QCoreApplication::applicationDirPath());
	if (dir.dirName() != QLatin1String("MacOS")) return QString();

	dir.cdUp();
	dir.cdUp();

	QString path(dir.path());
	if (path.length() > 0 && path.right(1) == "/") path.chop(1);
	return path;
}

static inline QString getMacOsBundleName() {
	return QFileInfo(getMacOsBundlePath()).baseName();
}

bool App::autoStartEnabled() {
	const QByteArray expectedWord(getMacOsBundleName().toUtf8());
	if (expectedWord.isEmpty()) {
		qInfo() << QStringLiteral("Application is not installed. Autostart unavailable.");
		return false;
	}

	QProcess process;
	process.start(OsascriptExecutable,
	              {"-e", "tell application \"System Events\" to get the name of every login item"});
	if (!process.waitForFinished()) {
		qWarning() << QStringLiteral("Unable to execute properly: `%1` (%2).")
		                  .arg(OsascriptExecutable)
		                  .arg(process.errorString());
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
					if (!strncmp(word, expectedWord, size_t(p - word))) return true;
					word = p + 1;
				}
			default:
				break;
		}
	}

	return false;
}
#else
bool App::autoStartEnabled() {
	return QSettings(AutoStartSettingsFilePath, QSettings::NativeFormat).value(EXECUTABLE_NAME).isValid();
}
#endif // ifdef Q_OS_LINUX

#ifdef Q_OS_LINUX

void App::setAutoStart(bool enabled) {
	if (enabled == mAutoStart) return;

	QDir dir(AutoStartDirectory);
	if (!dir.exists() && !dir.mkpath(AutoStartDirectory)) {
		qWarning() << QStringLiteral("Unable to build autostart dir path: `%1`.").arg(AutoStartDirectory);
		return;
	}

	const QString confPath(AutoStartDirectory + EXECUTABLE_NAME ".desktop");
	if (generateDesktopFile(confPath, !enabled, true)) {
		mAutoStart = enabled;
	}
}

#elif defined(Q_OS_MACOS)

void App::setAutoStart(bool enabled) {
	if (enabled == mAutoStart) return;

	if (getMacOsBundlePath().isEmpty()) {
		qWarning() << QStringLiteral("Application is not installed. Unable to change autostart state.");
		return;
	}

	if (enabled)
		QProcess::execute(OsascriptExecutable,
		                  {"-e", "tell application \"System Events\" to make login item at end with properties"
		                         "{ path: \"" +
		                             getMacOsBundlePath() + "\", hidden: false }"});
	else
		QProcess::execute(OsascriptExecutable, {"-e", "tell application \"System Events\" to delete login item \"" +
		                                                  getMacOsBundleName() + "\""});

	mAutoStart = enabled;
}

#else

void App::setAutoStart(bool enabled) {
	QSettings settings(AutoStartSettingsFilePath, QSettings::NativeFormat);
	if (enabled) settings.setValue(EXECUTABLE_NAME, QDir::toNativeSeparators(applicationFilePath()));
	else settings.remove(EXECUTABLE_NAME);

	mAutoStart = enabled;
}

#endif // ifdef Q_OS_LINUX

// -----------------------------------------------------------------------------
//		End Autostart
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------

App::App(int &argc, char *argv[])
    : SingleApplication(argc, argv, true, Mode::User | Mode::ExcludeAppPath | Mode::ExcludeAppVersion) {
	// Do not use APPLICATION_NAME here.
	// The EXECUTABLE_NAME will be used in qt standard paths. It's our goal.
	QDir::setCurrent(
	    QCoreApplication::applicationDirPath()); // Set working directory as the executable to allow relative paths.
	QThread::currentThread()->setPriority(QThread::HighPriority);
	qDebug() << "app thread is" << QThread::currentThread();
	lDebug() << "Starting app with Qt version" << qVersion();
	QCoreApplication::setApplicationName(EXECUTABLE_NAME);
	QApplication::setOrganizationDomain(EXECUTABLE_NAME);
	QCoreApplication::setApplicationVersion(APPLICATION_SEMVER);
	// CarshReporter must be call after app initialization like names.
#ifdef HAVE_CRASH_HANDLER
	CrashReporter::start();
#else
	lWarning() << "[Main] The application doesn't support the CrashReporter.";
#endif

	// If not OpenGL, createRender is never call.
	QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
	setWindowIcon(QIcon(Constants::WindowIconPath));
	initFonts();
	//-------------------
	mOIDCRefreshTimer.setInterval(1000);
	mOIDCRefreshTimer.setSingleShot(false);

	mLinphoneThread = new Thread(this);

	init();
	lInfo() << QStringLiteral("Starting application %1 %2 %3 %4")
	               .arg(APPLICATION_NAME)
	               .arg("(bin:")
	               .arg(EXECUTABLE_NAME)
	               .arg("). Version:%1 Os:%2 Qt:%3")
	               .arg(applicationVersion())
	               .arg(Utils::getOsProduct())
	               .arg(qVersion());
	lInfo() << "at " << QDir().absolutePath();
	mCurrentDate = QDate::currentDate();
	mAutoStart = autoStartEnabled();
	mDateUpdateTimer.setInterval(60000);
	mDateUpdateTimer.setSingleShot(false);
	connect(&mDateUpdateTimer, &QTimer::timeout, this, [this] {
		auto date = QDate::currentDate();
		if (date != mCurrentDate) {
			mCurrentDate = date;
			emit currentDateChanged();
		}
	});
	mEventCountNotifier = new EventCountNotifier(this);
	mDateUpdateTimer.start();

#ifdef Q_OS_LINUX
	exportDesktopFile();
#endif
}

App::~App() {
}

void App::setSelf(QSharedPointer<App>(me)) {
	mCoreModelConnection = SafeConnection<App, CoreModel>::create(me, CoreModel::getInstance());
	mCoreModelConnection->makeConnectToModel(&CoreModel::callCreated,
	                                         [this](const std::shared_ptr<linphone::Call> &call) {
		                                         if (call->getDir() == linphone::Call::Dir::Incoming) return;
		                                         auto callCore = CallCore::create(call);
		                                         mCoreModelConnection->invokeToCore([this, callCore] {
			                                         auto callGui = new CallGui(callCore);
			                                         auto win = getOrCreateCallsWindow(QVariant::fromValue(callGui));
			                                         Utils::smartShowWindow(win);
			                                         auto mainwin = getMainWindow();
			                                         QMetaObject::invokeMethod(mainwin, "callCreated");
			                                         lDebug() << "App : call created" << callGui;
		                                         });
	                                         });
	mCoreModelConnection->makeConnectToModel(&CoreModel::requestRestart, [this]() {
		mCoreModelConnection->invokeToCore([this]() {
			lInfo() << log().arg("Restarting");
			restart();
		});
	});
	mCoreModelConnection->makeConnectToModel(&CoreModel::requestFetchConfig, [this](QString path,
	                                                                                bool askForConfirmation) {
		mCoreModelConnection->invokeToCore([this, path, askForConfirmation]() {
			auto apply = [this, path] {
				mCoreModelConnection->invokeToModel([this, path]() { CoreModel::getInstance()->setFetchConfig(path); });
			};
			auto callback = [this, path, askForConfirmation]() {
				//: Voulez-vous télécharger et appliquer la configuration depuis cette adresse ?
				RequestDialog *obj = new RequestDialog(tr("remote_provisioning_dialog"), path);
				connect(obj, &RequestDialog::result, this, [this, obj, path](int result) {
					if (result == 1) {
						mCoreModelConnection->invokeToModel(
						    [this, path]() { CoreModel::getInstance()->setFetchConfig(path); });
					} else if (result == 0) {
						mCoreModelConnection->invokeToModel([]() { CliModel::getInstance()->resetProcesses(); });
					}
					obj->deleteLater();
				});
				QMetaObject::invokeMethod(getMainWindow(), "showConfirmationPopup", QVariant::fromValue(obj));
			};
			if (!getMainWindow()) { // Delay
				if (askForConfirmation)
					connect(this, &App::mainWindowChanged, this, callback, Qt::SingleShotConnection);
				else connect(this, &App::mainWindowChanged, this, apply, Qt::SingleShotConnection);
			} else {
				if (askForConfirmation) callback();
				else apply();
			}
		});
	});
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::globalStateChanged,
	    [this](const std::shared_ptr<linphone::Core> &core, linphone::GlobalState gstate, const std::string &message) {
		    mCoreModelConnection->invokeToCore([this, gstate] {
			    setCoreStarted(gstate == linphone::GlobalState::On);
			    if (gstate == linphone::GlobalState::Configuring) {
				    if (mMainWindow) {
					    QMetaObject::invokeMethod(mMainWindow, "openSSOPage", Qt::DirectConnection);
				    } else {
					    connect(
					        this, &App::mainWindowChanged, this,
					        [this] {
						        mCoreModelConnection->invokeToModel([this] {
							        auto gstate = CoreModel::getInstance()->getCore()->getGlobalState();
							        if (gstate == linphone::GlobalState::Configuring)
								        mCoreModelConnection->invokeToCore([this] {
									        if (mMainWindow)
										        QMetaObject::invokeMethod(mMainWindow, "openSSOPage",
										                                  Qt::DirectConnection);
								        });
						        });
					        },
					        Qt::SingleShotConnection);
				    }
			    }
		    });
	    });
	mCoreModelConnection->makeConnectToModel(&CoreModel::authenticationRequested, &App::onAuthenticationRequested);
	// Config error message
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::configuringStatus, [this](const std::shared_ptr<linphone::Core> &core,
	                                          linphone::ConfiguringState status, const std::string &message) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    if (mIsRestarting && status == linphone::ConfiguringState::Failed) {
			    mCoreModelConnection->invokeToCore([this, message]() {
				    mustBeInMainThread(log().arg(Q_FUNC_INFO));
				    //: Error
				    Utils::showInformationPopup(
				        tr("info_popup_error_title"),
				        tr("info_popup_configuration_failed_message").arg(Utils::coreStringToAppString(message)),
				        false);
			    });
		    }
	    });
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::accountAdded,
	    [this](const std::shared_ptr<linphone::Core> &core, const std::shared_ptr<linphone::Account> &account) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    if (CoreModel::getInstance()->mConfigStatus == linphone::ConfiguringState::Successful) {
			    bool accountConnected = account && account->getState() == linphone::RegistrationState::Ok;
			    // update settings if case config contains changes
			    if (mSettings) mSettings->reloadSettings();
			    mCoreModelConnection->invokeToCore([this, accountConnected]() {
				    mustBeInMainThread(log().arg(Q_FUNC_INFO));
				    // There is an account added by a remote provisioning, force switching to main  page
				    // because the account may not be connected already
				    if (mPossiblyLookForAddedAccount) {
					    QMetaObject::invokeMethod(mMainWindow, "openMainPage", Qt::DirectConnection,
					                              Q_ARG(QVariant, accountConnected));
				    }
				    mPossiblyLookForAddedAccount = false;
				    // setLocale(mSettings->getConfigLocale());
				    // setAutoStart(mSettings->getAutoStart());
				    // setQuitOnLastWindowClosed(mSettings->getExitOnClose());
			    });
		    }
	    });

	// Synchronize state for because linphoneCore was ran before any connections.
	mCoreModelConnection->invokeToModel([this]() {
		auto state = CoreModel::getInstance()->getCore()->getGlobalState();
		mCoreModelConnection->invokeToCore([this, state] {
			setCoreStarted(state == linphone::GlobalState::On);
			if (state == linphone::GlobalState::Configuring) {
				if (mMainWindow) {
					QMetaObject::invokeMethod(mMainWindow, "openSSOPage", Qt::DirectConnection);
				} else {
					connect(
					    this, &App::mainWindowChanged, this,
					    [this] {
						    mCoreModelConnection->invokeToModel([this] {
							    auto gstate = CoreModel::getInstance()->getCore()->getGlobalState();
							    if (gstate == linphone::GlobalState::Configuring)
								    mCoreModelConnection->invokeToCore([this] {
									    if (mMainWindow)
										    QMetaObject::invokeMethod(mMainWindow, "openSSOPage", Qt::DirectConnection);
								    });
						    });
					    },
					    Qt::SingleShotConnection);
				}
			}
		});
	});

	mCoreModelConnection->makeConnectToModel(&CoreModel::unreadNotificationsChanged, [this] {
		int n = mEventCountNotifier->getCurrentEventCount();
		mCoreModelConnection->invokeToCore([this, n] { mEventCountNotifier->notifyEventCount(n); });
	});
	mCoreModelConnection->makeConnectToModel(&CoreModel::defaultAccountChanged, [this] {
		int n = mEventCountNotifier->getCurrentEventCount();
		mCoreModelConnection->invokeToCore([this, n] {
			mEventCountNotifier->notifyEventCount(n);
			emit defaultAccountChanged();
		});
	});

	// Check update
	mCoreModelConnection->makeConnectToModel(
	    &CoreModel::versionUpdateCheckResultReceived,
	    [this](const std::shared_ptr<linphone::Core> &core, linphone::VersionUpdateCheckResult result,
	           const std::string &version, const std::string &url, bool checkRequestedByUser) {
		    mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		    mCoreModelConnection->invokeToCore([this, result, version, url, checkRequestedByUser] {
			    switch (result) {
				    case linphone::VersionUpdateCheckResult::Error:
					    Utils::showInformationPopup(tr("info_popup_error_title"),
					                                //: An error occured while trying to check update. Please
					                                //: try again later or contact support team.
					                                tr("info_popup_error_checking_update"), false);
					    break;
				    case linphone::VersionUpdateCheckResult::NewVersionAvailable: {
					    QString downloadLink =
					        QStringLiteral("<a href='%1'><font color='DefaultStyle.main2_600'>%2</a>")
					            .arg(Utils::coreStringToAppString(url))
					            //: Download it !
					            .arg(tr("info_popup_new_version_download_label"));
					    Utils::showInformationPopup(
					        //: New version available !
					        tr("info_popup_new_version_available_title"),
					        //: A new version of Linphone (%1) is available. %2
					        tr("info_popup_new_version_available_message")
					            .arg(Utils::coreStringToAppString(version))
					            .arg(downloadLink));
					    break;
				    }
				    case linphone::VersionUpdateCheckResult::UpToDate:
					    if (checkRequestedByUser)
						    //: Up to date
						    Utils::showInformationPopup(tr("info_popup_version_up_to_date_title"),
						                                //: Your version is up to date
						                                tr("info_popup_version_up_to_date_message"));
			    }
		    });
	    });

	mCoreModelConnection->makeConnectToModel(&CoreModel::oidcRemainingTimeBeforeTimeoutChanged,
	                                         [this](int remainingTime) {
		                                         mCoreModelConnection->invokeToCore([this, remainingTime] {
			                                         mRemainingTimeBeforeOidcTimeout = remainingTime;
			                                         emit remainingTimeBeforeOidcTimeoutChanged();
		                                         });
	                                         });
	mCoreModelConnection->makeConnectToCore(&App::lForceOidcTimeout, [this] {
		qDebug() << "App: force oidc timeout";
		mCoreModelConnection->invokeToModel([this] { emit CoreModel::getInstance()->forceOidcTimeout(); });
	});
	mCoreModelConnection->makeConnectToModel(&CoreModel::timeoutTimerStarted, [this]() {
		qDebug() << "App: oidc timer started";
		mCoreModelConnection->invokeToCore([this] { mOIDCRefreshTimer.start(); });
	});
	mCoreModelConnection->makeConnectToModel(&CoreModel::timeoutTimerStopped, [this]() {
		qDebug() << "App: oidc timer stopped";
		mCoreModelConnection->invokeToCore([this] { mOIDCRefreshTimer.stop(); });
	});
	connect(&mOIDCRefreshTimer, &QTimer::timeout, this, [this]() {
		mCoreModelConnection->invokeToModel([this] { CoreModel::getInstance()->refreshOidcRemainingTime(); });
	});

	//---------------------------------------------------------------------------------------------
	mCliModelConnection = SafeConnection<App, CliModel>::create(me, CliModel::getInstance());
	mCliModelConnection->makeConnectToCore(&App::receivedMessage, [this](int, const QByteArray &byteArray) {
		QString command(byteArray);
		if (command.isEmpty()) {
			lInfo() << log().arg("Check with CliModel for commands");
			mCliModelConnection->invokeToModel([]() { CliModel::getInstance()->runProcess(); });
		} else {
			lInfo() << log().arg("Received command from other application: `%1`.").arg(command);
			mCliModelConnection->invokeToModel([command]() { CliModel::getInstance()->executeCommand(command); });
		}
	});
	mCliModelConnection->makeConnectToModel(&CliModel::showMainWindow, [this]() {
		mCliModelConnection->invokeToCore([this]() { Utils::smartShowWindow(getMainWindow()); });
	});
}

App *App::getInstance() {
	return dynamic_cast<App *>(QApplication::instance());
}

Thread *App::getLinphoneThread() {
	return App::getInstance() ? App::getInstance()->mLinphoneThread : nullptr;
}

Notifier *App::getNotifier() const {
	return mNotifier;
}

EventCountNotifier *App::getEventCountNotifier() {
	return mEventCountNotifier;
}

int App::getEventCount() const {
	return mEventCountNotifier ? mEventCountNotifier->getEventCount() : 0;
}

//-----------------------------------------------------------
//		Initializations
//-----------------------------------------------------------

void App::init() {
	// Console Commands
	createCommandParser();
	mParser->parse(this->arguments());
	// TODO : Update languages for command translations.

	createCommandParser(); // Recreate parser in order to use translations from config.
	mParser->process(*this);

	if (mParser->isSet("help")) {
		mParser->showHelp();
		::exit(EXIT_SUCCESS);
	}

	if (mParser->isSet("version")) {
		mParser->showVersion();
		::exit(EXIT_SUCCESS);
	}

	if (!mLinphoneThread->isRunning()) {
		lInfo() << log().arg("Starting Thread");
		mLinphoneThread->start();
		while (!mLinphoneThread->getThreadId()) // Wait for running thread
			QThread::msleep(100);
	}

	// Init locale.
	mTranslatorCore = new DefaultTranslatorCore(this);
	mDefaultTranslatorCore = new DefaultTranslatorCore(this);
	initLocale();

	lInfo() << log().arg("Display server : %1").arg(platformName());
}

void App::initCore() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	// Core. Manage the logger so it must be instantiate at first.
	CoreModel::create("", mLinphoneThread);
	if (mParser->isSet("verbose")) QtLogger::enableVerbose(true);
	if (mParser->isSet("qt-logs-only")) QtLogger::enableQtOnly(true);
	qDebug() << "linphone thread is" << mLinphoneThread;
	QMetaObject::invokeMethod(
	    mLinphoneThread->getThreadId(),
	    [this, settings = mSettings]() mutable {
		    lInfo() << log().arg("Updating downloaded codec files");
		    ToolModel::updateCodecs(); // removing codec updates suffic (.in) before the core is created.
		    lInfo() << log().arg("Starting Core");
		    CoreModel::getInstance()->start();
		    ToolModel::loadDownloadedCodecs();
		    lDebug() << log().arg("Creating SettingsModel");
		    SettingsModel::create();
		    lDebug() << log().arg("Creating SettingsCore");
		    settings = SettingsCore::create();
		    // Update the download folder if set in the configuration file
		    CoreModel::getInstance()->setPathsAfterCreation();
		    lDebug() << log().arg("Checking downloaded codecs updates");
		    Utils::checkDownloadedCodecsUpdates();
		    lDebug() << log().arg("Setting Video Codec Priority Policy");
		    CoreModel::getInstance()->getCore()->setVideoCodecPriorityPolicy(linphone::CodecPriorityPolicy::Auto);
		    lDebug() << log().arg("Creating Ui");
		    QMetaObject::invokeMethod(App::getInstance()->thread(), [this, settings] {
			    // Initialize DestopTools here to have logs into files in case of errors.
			    DesktopTools::init();

			// CrashReporter must be call after app initialization like names.
#ifdef HAVE_CRASH_HANDLER
			    lInfo() << log().arg("Start CrashReporter.");
			    bool status = CrashReporter::start();
			    if (!status) {
				    lWarning() << log().arg("CrashReporter could not start.");
			    }
#else
	lWarning() << "[Main] The application doesn't support the CrashReporter.";
#endif
			    // QML
			    mEngine = new QQmlApplicationEngine(this);
			    assert(mEngine);
			    // Provide `+custom` folders for custom components and `5.9` for old components.
			    QStringList selectors("custom");
			    const QVersionNumber &version = QLibraryInfo::version();
			    if (version.majorVersion() == 5 && version.minorVersion() == 9) selectors.push_back("5.9");
			    auto selector = new QQmlFileSelector(mEngine, mEngine);
			    selector->setExtraSelectors(selectors);
			    lInfo() << log().arg("Activated selectors:") << selector->selector()->allSelectors();

			    mEngine->rootContext()->setContextProperty("applicationDirPath", QGuiApplication::applicationDirPath());
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
#ifdef APPLICATION_LICENCE_URL
			    mEngine->rootContext()->setContextProperty("applicationLicenceUrl", APPLICATION_LICENCE_URL);
#else
				mEngine->rootContext()->setContextProperty("applicationLicenceUrl", "");
#endif
#ifdef COPYRIGHT_RANGE_DATE
			    mEngine->rootContext()->setContextProperty("copyrightRangeDate", COPYRIGHT_RANGE_DATE);
#else
				mEngine->rootContext()->setContextProperty("copyrightRangeDate", "");
#endif
			    mEngine->rootContext()->setContextProperty("applicationName", APPLICATION_NAME);
			    mEngine->rootContext()->setContextProperty("executableName", EXECUTABLE_NAME);

			    initCppInterfaces();
			    mEngine->addImageProvider(ImageProvider::ProviderId, new ImageProvider());
			    mEngine->addImageProvider(EmojiProvider::ProviderId, new EmojiProvider());
			    mEngine->addImageProvider(AvatarProvider::ProviderId, new AvatarProvider());
			    mEngine->addImageProvider(ScreenProvider::ProviderId, new ScreenProvider());
			    mEngine->addImageProvider(WindowProvider::ProviderId, new WindowProvider());
			    mEngine->addImageProvider(WindowIconProvider::ProviderId, new WindowIconProvider());
			    mEngine->addImageProvider(ThumbnailProvider::ProviderId, new ThumbnailProvider());

			    // Enable notifications.
			    mNotifier = new Notifier(mEngine);
			    mEngine->setObjectOwnership(settings.get(), QQmlEngine::CppOwnership);
			    mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);

			    connect(this, &App::coreStartedChanged, this, [this] {
				    if (mCoreStarted) {
					    if (!mAccountList) setAccountList(AccountList::create());
					    else {
						    mAccountList->setInitialized(false);
						    mAccountList->lUpdate(true);
					    }
					    connect(mAccountList.get(), &AccountList::defaultAccountChanged, this,
					            &App::currentAccountChanged);
					    // Update global unread Notifications when an account updates his unread Notifications
					    connect(mAccountList.get(), &AccountList::unreadNotificationsChanged, this, [this]() {
						    lDebug() << "unreadNotificationsChanged of AccountList";
						    mCoreModelConnection->invokeToModel([this] {
							    int n = mEventCountNotifier->getCurrentEventCount();
							    mCoreModelConnection->invokeToCore(
							        [this, n] { mEventCountNotifier->notifyEventCount(n); });
						    });
					    });
					    if (!mCallList) setCallList(CallList::create());
					    else mCallList->lUpdate();
					    if (!mChatList) setChatList(ChatList::create());
					    else mChatList->lUpdate();
					    disconnect(this, &App::coreStartedChanged, this, nullptr);
				    }
			    });

			    // if (!mSettings) {
			    mSettings = settings;
			    setLocale(settings->getConfigLocale());
			    setAutoStart(settings->getAutoStart());
			    setQuitOnLastWindowClosed(settings->getExitOnClose());
			    mEngine->setObjectOwnership(mSettings.get(), QQmlEngine::CppOwnership);

			    connect(mSettings.get(), &SettingsCore::exitOnCloseChanged, this, &App::onExitOnCloseChanged,
			            Qt::UniqueConnection);
			    QObject::connect(mSettings.get(), &SettingsCore::autoStartChanged, [this]() {
				    mustBeInMainThread(log().arg(Q_FUNC_INFO));
				    setAutoStart(mSettings->getAutoStart());
			    });
			    QObject::connect(mSettings.get(), &SettingsCore::configLocaleChanged, [this]() {
				    mustBeInMainThread(log().arg(Q_FUNC_INFO));
				    if (mSettings) setLocale(mSettings->getConfigLocale());
			    });
			    connect(mSettings.get(), &SettingsCore::exitOnCloseChanged, this, &App::onExitOnCloseChanged,
			            Qt::UniqueConnection);
			    // } else {
			    //     setLocale(settings->getConfigLocale());
			    //     setAutoStart(settings->getAutoStart());
			    //     setQuitOnLastWindowClosed(settings->getExitOnClose());
			    // }
			    const QUrl url("qrc:/qt/qml/Linphone/view/Page/Window/Main/MainWindow.qml");
			    QObject::connect(
			        mEngine, &QQmlApplicationEngine::objectCreated, this,
			        [this, url](QObject *obj, const QUrl &objUrl) {
				        if (url == objUrl) {
					        if (!obj) {
						        lCritical() << log().arg("MainWindow.qml couldn't be load. The app will exit");
						        exit(-1);
					        }
					        auto window = qobject_cast<QQuickWindow *>(obj);
					        setMainWindow(window);
#if defined(__APPLE__)
					        setMacOSDockActions();
#else
					        // Enable TrayIconSystem.
					        if (!QSystemTrayIcon::isSystemTrayAvailable())
						        qWarning("System tray not found on this system.");
					        else setSysTrayIcon();
#endif // if defined(__APPLE__)

					        static bool firstOpen = true;
					        if (!firstOpen || !mParser->isSet("minimized")) {
						        lDebug() << log().arg("Openning window");
						        if (window) window->show();
					        } else lInfo() << log().arg("Stay minimized");
					        firstOpen = false;
					        lInfo() << log().arg("Checking remote provisioning");
					        if (mIsRestarting) {
						        if (CoreModel::getInstance()->mConfigStatus == linphone::ConfiguringState::Failed) {
							        QMetaObject::invokeMethod(thread(), [this]() {
								        mustBeInMainThread(log().arg(Q_FUNC_INFO));
								        auto message = CoreModel::getInstance()->mConfigMessage;
								        //: not reachable
								        if (message.isEmpty()) message = tr("configuration_error_detail");
								        lWarning() << log().arg("Configuration failed (reason: %1)").arg(message);
								        //: Error
								        Utils::showInformationPopup(
								            tr("info_popup_error_title"),
								            //: Remote provisioning failed : %1
								            tr("info_popup_configuration_failed_message").arg(message), false);
							        });
						        } else if (CoreModel::getInstance()->mConfigStatus ==
						                   linphone::ConfiguringState::Successful) {
							        lInfo() << log().arg("Configuration succeed");
							        mPossiblyLookForAddedAccount = true;
							        if (mAccountList && mAccountList->getCount() > 0) {
								        auto defaultConnected =
								            mAccountList->getDefaultAccountCore() &&
								            mAccountList->getDefaultAccountCore()->getRegistrationState() ==
								                LinphoneEnums::RegistrationState::Ok;
								        QMetaObject::invokeMethod(mMainWindow, "openMainPage", Qt::DirectConnection,
								                                  Q_ARG(QVariant, defaultConnected));
							        }
						        }
					        }
					        checkForUpdate();
					        setIsRestarting(false);
					        window->show();
					        window->requestActivate();

					        //---------------------------------------------------------------------------------------------
					        lDebug() << log().arg("Creating KeyboardShortcuts");
					        KeyboardShortcuts::create(getMainWindow());
				        }
			        },
			        Qt::QueuedConnection);

			    mEngine->load(url);
		    });
	    },
	    Qt::BlockingQueuedConnection);
}

static inline bool installLocale(App &app, QTranslator &translator, const QLocale &locale) {
	bool ok = translator.load(locale.name(), Constants::LanguagePath);
	ok = ok && app.installTranslator(&translator);
	if (ok) QLocale::setDefault(locale);
	return ok;
}

void App::initLocale() {
	// Try to use preferred locale.
	QString locale;

	// Use english. This default translator is used if there are no found translations in others loads
	mLocale = QLocale(QLocale::English);
	if (!installLocale(*this, *mDefaultTranslatorCore, mLocale)) qFatal("Unable to install default translator.");

	//	if (installLocale(*this, *mTranslatorCore, getLocale())) {
	//		qDebug() << "installed locale" << getLocale().name();
	//		return;
	//	}

	// Try to use system locale.
	// #ifdef Q_OS_MACOS
	// Use this workaround if there is still an issue about detecting wrong language from system on Mac. Qt doesn't
	// use the current system language on QLocale::system(). So we need to get it from user settings and overwrite
	// its Locale.
	//	QSettings settings;
	//	QString preferredLanguage = settings.value("AppleLanguages").toStringList().first();
	//	QStringList qtLocale = QLocale::system().name().split('_');
	//	if(qtLocale[0] != preferredLanguage){
	//		qInfo() << "Override Qt language from " << qtLocale[0] << " to the preferred language : " <<
	// preferredLanguage; 		qtLocale[0] = preferredLanguage;
	//	}
	//	QLocale sysLocale = QLocale(qtLocale.join('_'));
	// #else
	QLocale sysLocale(QLocale::system().name()); // Use Locale from name because Qt has a bug where it didn't use
	                                             // the QLocale::language (aka : translator.language !=
	                                             // locale.language) on Mac. #endif
	if (installLocale(*this, *mTranslatorCore, sysLocale)) {
		qDebug() << "installed sys locale" << sysLocale.name();
		setLocale(sysLocale.name());
	}
}

void App::initCppInterfaces() {
	qmlRegisterSingletonType<App>(Constants::MainQmlUri, 1, 0, "AppCpp",
	                              [](QQmlEngine *engine, QJSEngine *) -> QObject * { return App::getInstance(); });
	qmlRegisterSingletonType<LoginPage>(
	    Constants::MainQmlUri, 1, 0, "LoginPageCpp", [](QQmlEngine *engine, QJSEngine *) -> QObject * {
		    static auto loginPage = new LoginPage();
		    App::getInstance()->mEngine->setObjectOwnership(loginPage, QQmlEngine::CppOwnership);
		    return loginPage;
	    });
	qmlRegisterSingletonType<RegisterPage>(
	    Constants::MainQmlUri, 1, 0, "RegisterPageCpp", [](QQmlEngine *engine, QJSEngine *) -> QObject * {
		    static RegisterPage *registerPage = new RegisterPage();
		    App::getInstance()->mEngine->setObjectOwnership(registerPage, QQmlEngine::CppOwnership);
		    return registerPage;
	    });
	qmlRegisterSingletonType<Constants>(
	    "ConstantsCpp", 1, 0, "ConstantsCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new Constants(engine); });
	qmlRegisterSingletonType<Utils>("UtilsCpp", 1, 0, "UtilsCpp",
	                                [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new Utils(engine); });
	qmlRegisterSingletonType<DesktopTools>(
	    "DesktopToolsCpp", 1, 0, "DesktopToolsCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new DesktopTools(engine); });
	qmlRegisterSingletonType<EnumsToString>(
	    "EnumsToStringCpp", 1, 0, "EnumsToStringCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new EnumsToString(engine); });

	qmlRegisterSingletonType<SettingsCore>(
	    "SettingsCpp", 1, 0, "SettingsCpp",
	    [this](QQmlEngine *engine, QJSEngine *) -> QObject * { return mSettings.get(); });

	qmlRegisterSingletonType<AccessibilityHelper>(
	    "AccessibilityHelperCpp", 1, 0, "AccessibilityHelperCpp",
	    [](QQmlEngine *engine, QJSEngine *) -> QObject * { return new AccessibilityHelper(engine); });

	qmlRegisterType<FocusHelper>("CustomControls", 1, 0, "FocusHelper");

	qmlRegisterType<DashRectangle>(Constants::MainQmlUri, 1, 0, "DashRectangle");
	qmlRegisterType<PhoneNumberProxy>(Constants::MainQmlUri, 1, 0, "PhoneNumberProxy");
	qmlRegisterType<VariantObject>(Constants::MainQmlUri, 1, 0, "VariantObject");
	qmlRegisterType<VariantList>(Constants::MainQmlUri, 1, 0, "VariantList");

	qmlRegisterType<ParticipantInfoProxy>(Constants::MainQmlUri, 1, 0, "ParticipantInfoProxy");
	qmlRegisterType<ParticipantProxy>(Constants::MainQmlUri, 1, 0, "ParticipantProxy");
	qmlRegisterType<ParticipantGui>(Constants::MainQmlUri, 1, 0, "ParticipantGui");
	qmlRegisterType<ConferenceInfoProxy>(Constants::MainQmlUri, 1, 0, "ConferenceInfoProxy");
	qmlRegisterType<ConferenceInfoGui>(Constants::MainQmlUri, 1, 0, "ConferenceInfoGui");

	qmlRegisterType<PhoneNumberProxy>(Constants::MainQmlUri, 1, 0, "PhoneNumberProxy");
	qmlRegisterUncreatableType<PhoneNumber>(Constants::MainQmlUri, 1, 0, "PhoneNumber", QLatin1String("Uncreatable"));
	qmlRegisterType<AccountGui>(Constants::MainQmlUri, 1, 0, "AccountGui");
	qmlRegisterType<AccountProxy>(Constants::MainQmlUri, 1, 0, "AccountProxy");
	qmlRegisterType<AccountDeviceProxy>(Constants::MainQmlUri, 1, 0, "AccountDeviceProxy");
	qmlRegisterType<AccountDeviceGui>(Constants::MainQmlUri, 1, 0, "AccountDeviceGui");
	qmlRegisterUncreatableType<AccountCore>(Constants::MainQmlUri, 1, 0, "AccountCore", QLatin1String("Uncreatable"));
	qmlRegisterUncreatableType<CallCore>(Constants::MainQmlUri, 1, 0, "CallCore", QLatin1String("Uncreatable"));
	qmlRegisterType<CallHistoryProxy>(Constants::MainQmlUri, 1, 0, "CallHistoryProxy");
	qmlRegisterType<CallGui>(Constants::MainQmlUri, 1, 0, "CallGui");
	qmlRegisterType<CallProxy>(Constants::MainQmlUri, 1, 0, "CallProxy");
	qmlRegisterType<ChatProxy>(Constants::MainQmlUri, 1, 0, "ChatProxy");
	qmlRegisterType<ChatGui>(Constants::MainQmlUri, 1, 0, "ChatGui");
	qmlRegisterType<EventLogGui>(Constants::MainQmlUri, 1, 0, "EventLogGui");
	qmlRegisterType<ChatMessageGui>(Constants::MainQmlUri, 1, 0, "ChatMessageGui");
	qmlRegisterType<EventLogList>(Constants::MainQmlUri, 1, 0, "EventLogList");
	qmlRegisterType<EventLogProxy>(Constants::MainQmlUri, 1, 0, "EventLogProxy");
	qmlRegisterType<ChatMessageContentProxy>(Constants::MainQmlUri, 1, 0, "ChatMessageContentProxy");
	qmlRegisterType<ChatMessageFileProxy>(Constants::MainQmlUri, 1, 0, "ChatMessageFileProxy");
	qmlRegisterType<ChatMessageContentGui>(Constants::MainQmlUri, 1, 0, "ChatMessageContentGui");
	qmlRegisterUncreatableType<ConferenceCore>(Constants::MainQmlUri, 1, 0, "ConferenceCore",
	                                           QLatin1String("Uncreatable"));
	qmlRegisterType<ConferenceGui>(Constants::MainQmlUri, 1, 0, "ConferenceGui");
	qmlRegisterType<FriendGui>(Constants::MainQmlUri, 1, 0, "FriendGui");
	qmlRegisterUncreatableType<FriendCore>(Constants::MainQmlUri, 1, 0, "FriendCore", QLatin1String("Uncreatable"));
	qmlRegisterType<MagicSearchProxy>(Constants::MainQmlUri, 1, 0, "MagicSearchProxy");
	qmlRegisterType<MagicSearchList>(Constants::MainQmlUri, 1, 0, "MagicSearchList");
	qmlRegisterType<CameraGui>(Constants::MainQmlUri, 1, 0, "CameraGui");
	qmlRegisterType<FPSCounter>(Constants::MainQmlUri, 1, 0, "FPSCounter");
	qmlRegisterType<EmojiModel>(Constants::MainQmlUri, 1, 0, "EmojiModel");
	qmlRegisterType<EmojiProxy>(Constants::MainQmlUri, 1, 0, "EmojiProxy");
	qmlRegisterType<ImdnStatusProxy>(Constants::MainQmlUri, 1, 0, "ImdnStatusProxy");
	qmlRegisterType<SoundPlayerGui>(Constants::MainQmlUri, 1, 0, "SoundPlayerGui");
	qmlRegisterType<RecorderGui>(Constants::MainQmlUri, 1, 0, "RecorderGui");

	qmlRegisterType<TimeZoneProxy>(Constants::MainQmlUri, 1, 0, "TimeZoneProxy");

	qmlRegisterType<ParticipantDeviceGui>(Constants::MainQmlUri, 1, 0, "ParticipantDeviceGui");
	qmlRegisterType<ParticipantDeviceProxy>(Constants::MainQmlUri, 1, 0, "ParticipantDeviceProxy");

	qmlRegisterUncreatableType<ScreenList>(Constants::MainQmlUri, 1, 0, "ScreenList", QLatin1String("Uncreatable"));
	qmlRegisterType<ScreenProxy>(Constants::MainQmlUri, 1, 0, "ScreenProxy");

	qmlRegisterUncreatableType<VideoSourceDescriptorCore>(Constants::MainQmlUri, 1, 0, "VideoSourceDescriptorCore",
	                                                      QLatin1String("Uncreatable"));
	qmlRegisterType<VideoSourceDescriptorGui>(Constants::MainQmlUri, 1, 0, "VideoSourceDescriptorGui");

	qmlRegisterUncreatableType<RequestDialog>(Constants::MainQmlUri, 1, 0, "RequestDialog",
	                                          QLatin1String("Uncreatable"));
	qmlRegisterType<LdapGui>(Constants::MainQmlUri, 1, 0, "LdapGui");
	qmlRegisterType<LdapProxy>(Constants::MainQmlUri, 1, 0, "LdapProxy");
	qmlRegisterType<CarddavGui>(Constants::MainQmlUri, 1, 0, "CarddavGui");
	qmlRegisterType<CarddavProxy>(Constants::MainQmlUri, 1, 0, "CarddavProxy");
	qmlRegisterType<PayloadTypeGui>(Constants::MainQmlUri, 1, 0, "PayloadTypeGui");
	qmlRegisterType<PayloadTypeProxy>(Constants::MainQmlUri, 1, 0, "PayloadTypeProxy");
	qmlRegisterType<PayloadTypeCore>(Constants::MainQmlUri, 1, 0, "PayloadTypeCore");
	qmlRegisterType<PayloadTypeCore>(Constants::MainQmlUri, 1, 0, "DownloadablePayloadTypeCore");

	LinphoneEnums::registerMetaTypes();
}

//------------------------------------------------------------

void App::initFonts() {
	lInfo() << "Loading Fonts";
	QStringList allFamilies;
	QDirIterator it(":/font/", QDirIterator::Subdirectories);
	while (it.hasNext()) {
		QString ttf = it.next();
		if (it.fileInfo().isFile()) {
			auto id = QFontDatabase::addApplicationFont(ttf);
			allFamilies << QFontDatabase::applicationFontFamilies(id);
		}
	}
	QDirIterator itEmojis(":/emoji/font/", QDirIterator::Subdirectories);
	while (itEmojis.hasNext()) {
		QString ttf = itEmojis.next();
		if (itEmojis.fileInfo().isFile()) {
			auto id = QFontDatabase::addApplicationFont(ttf);
			allFamilies << QFontDatabase::applicationFontFamilies(id);
		}
	}
#ifdef Q_OS_LINUX
	QDirIterator itFonts(":/linux/font/", QDirIterator::Subdirectories);
	while (itFonts.hasNext()) {
		QString ttf = itFonts.next();
		if (itFonts.fileInfo().isFile()) {
			auto id = QFontDatabase::addApplicationFont(ttf);
			allFamilies << QFontDatabase::applicationFontFamilies(id);
		}
	}
#else
	QDirIterator itFonts(":/other/font/", QDirIterator::Subdirectories);
	while (itFonts.hasNext()) {
		QString ttf = itFonts.next();
		if (itFonts.fileInfo().isFile()) {
			auto id = QFontDatabase::addApplicationFont(ttf);
			allFamilies << QFontDatabase::applicationFontFamilies(id);
		}
	}
#endif
	allFamilies.removeDuplicates();
	lInfo() << "Font families loaded:\n\t" << allFamilies.join("\n\t");
}

//------------------------------------------------------------

void App::clean() {
	mDateUpdateTimer.stop();
	if (mEngine) {
		mEngine->clearComponentCache();
		mEngine->clearSingletons();
		delete mEngine;
	}
	mEngine = nullptr;
	mSettings = nullptr; // Need it because of SettingsModel singleton for letting thread to remove it.
	// Wait 500ms to let time for log te be stored.
	// mNotifier destroyed in mEngine deletion as it is its parent
	// Hack: exec() must be used to process cleaning QSharedPointers memory. processEvents doesn't work.
	QTimer::singleShot(500, [this]() { exit(0); });
	exec();
	if (mLinphoneThread) {
		mLinphoneThread->exit();
		mLinphoneThread->wait();
		delete mLinphoneThread;
	}
}
void App::restart() {
	mCoreModelConnection->invokeToModel([this]() {
		FriendsManager::getInstance()->clearMaps();
		CoreModel::getInstance()->getCore()->stop();
		mCoreModelConnection->invokeToCore([this]() {
			setIsRestarting(true);
			if (mAccountList) mAccountList->resetData();
			if (mCallList) mCallList->resetData();
			if (mCallHistoryList) mCallHistoryList->resetData();
			if (mChatList) mChatList->resetData();
			if (mConferenceInfoList) mConferenceInfoList->resetData();
			closeCallsWindow();
			setMainWindow(nullptr);
			setCoreStarted(false);
			mEngine->clearComponentCache();
			mEngine->clearSingletons();
			delete mEngine;
			mEngine = nullptr;
			// if (mSettings) mSettings.reset();
			initCore();
			// Retrieve self from current Core/Model connection and reset Qt connections.
			// auto oldConnection = mCoreModelConnection;
			// oldConnection->mCore.lock();
			// auto me = oldConnection->mCore.mQData;
			// setSelf(me);
			// oldConnection->mCore.unlock();
			exit((int)StatusCode::gRestartCode);
		});
	});
}
void App::createCommandParser() {
	if (!mParser) delete mParser;

	mParser = new QCommandLineParser();
	//: "A free and open source SIP video-phone."
	mParser->setApplicationDescription(tr("application_description"));
	//: "Send an order to the application towards a command line"
	mParser->addPositionalArgument("command", tr("command_line_arg_order").replace("%1", APPLICATION_NAME),
	                               "[command]");
	mParser->addOptions({
	    //: "Show this help"
	    {{"h", "help"}, tr("command_line_option_show_help")},

	    //{"cli-help", tr("commandLineOptionCliHelp").replace("%1", APPLICATION_NAME)},

	    //:"Show app version"
	    {{"v", "version"}, tr("command_line_option_show_app_version")},

	    //{"config", tr("command_line_option_config").replace("%1", EXECUTABLE_NAME),
	    // tr("command_line_option_config_arg")},

	    {"fetch-config",
	     //: "Specify the linphone configuration file to be fetched. It will be merged with the current
	     //: configuration."
	     tr("command_line_option_config_to_fetch").replace("%1", EXECUTABLE_NAME),
	     //: "URL, path or file"
	     tr("command_line_option_config_to_fetch_arg")},

	    //{{"c", "call"}, tr("command_line_option_call").replace("%1", EXECUTABLE_NAME),
	    // tr("command_line_option_call_arg")},

	    {"minimized", tr("command_line_option_minimized")},

	    //: "Log to stdout some debug information while running"
	    {{"V", "verbose"}, tr("command_line_option_log_to_stdout")},

	    //: "Print only logs from the application"
	    {"qt-logs-only", tr("command_line_option_print_app_logs_only")},
	});
}
// Should be call only at first start
void App::sendCommand() {
	auto arguments = mParser->positionalArguments();
	if (mParser->isSet("fetch-config")) arguments << "fetch-config=" + mParser->value("fetch-config");
	static bool firstStart = true; // We can't erase positional arguments. So we get them on each restart.
	if (firstStart) {
		firstStart = false;
		if (isSecondary()) { // Send to primary
			if (arguments.size() > 0) {
				lDebug() << log().arg("Sending") << arguments;
				for (auto i : arguments) {
					sendMessage(i.toLocal8Bit(), -1);
				}
			} else {
				lDebug() << log().arg("No arguments. Sending show command");
				sendMessage("show", -1);
			}
		} else if (arguments.size() > 0) { // Execute
			lDebug() << log().arg("Executing ") << arguments;
			for (auto i : arguments) {
				QString command(i);
				receivedMessage(0, i.toLocal8Bit());
			}
		}
	} else if (isPrimary()) {
		lDebug() << log().arg("Run waiting process");
		receivedMessage(0, "");
	}
}

bool App::getCoreStarted() const {
	return mCoreStarted;
}

void App::setCoreStarted(bool started) {
	if (mCoreStarted != started) {
		mCoreStarted = started;
		emit coreStartedChanged(mCoreStarted);
	}
}

bool App::isRestarting() const {
	return mIsRestarting;
}

void App::setIsRestarting(bool restarting) {
	if (mIsRestarting != restarting) {
		mIsRestarting = restarting;
		emit isRestartingChanged(mIsRestarting);
	}
}

static QObject *findParentWindow(QObject *item) {
	return !item || item->isWindowType() ? item : findParentWindow(item->parent());
}

bool App::notify(QObject *receiver, QEvent *event) {
	bool done = true;
	try {
		done = QApplication::notify(receiver, event);
	} catch (const std::exception &ex) {
		lFatal() << log().arg("Exception has been catch in notify: %1").arg(ex.what());
	} catch (...) {
		lFatal() << log().arg("Generic exeption has been catch in notify");
	}
	if (event->type() == QEvent::MouseButtonPress) {
		auto window = findParentWindow(receiver);
		if (getMainWindow() == window && mAccountList) {
			auto defaultAccountCore = mAccountList->getDefaultAccountCore();
			if (defaultAccountCore && defaultAccountCore->getUnreadCallNotifications() > 0) {
				emit defaultAccountCore->lResetMissedCalls();
			}
		}
	}
	return done;
}

void App::handleAccountActivity(QSharedPointer<AccountCore> accountCore) {
	if (!accountCore) return;
	auto accountPresence = accountCore->getPresence();
	if ((mMainWindow && mMainWindow->isActive() || (mCallsWindow && mCallsWindow->isActive())) &&
	    accountPresence == LinphoneEnums::Presence::Away) {
		accountCore->lSetPresence(LinphoneEnums::Presence::Online, false);
	} else if (((!mMainWindow || !mMainWindow->isActive() || !mMainWindow->isVisible()) &&
	            (!mCallsWindow || !mCallsWindow->isActive() || !mCallsWindow->isVisible())) &&
	           accountPresence == LinphoneEnums::Presence::Online) {
		accountCore->lSetPresence(LinphoneEnums::Presence::Away, false);
	}
}

void App::handleAppActivity() {
	if (mAccountList) {
		for (auto &account : mAccountList->getSharedList<AccountCore>())
			handleAccountActivity(account);
	} else {
		connect(
		    this, &App::accountsChanged, this,
		    [this] {
			    if (mAccountList) {
				    for (auto &account : mAccountList->getSharedList<AccountCore>())
					    handleAccountActivity(account);
			    }
		    },
		    Qt::SingleShotConnection);
	}
}

QQuickWindow *App::getCallsWindow() {
	return mCallsWindow;
}

QQuickWindow *App::getOrCreateCallsWindow(QVariant callGui) {
	mustBeInMainThread(getClassName());
	if (!mCallsWindow) {
		const QUrl callUrl("qrc:/qt/qml/Linphone/view/Page/Window/Call/CallsWindow.qml");

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
		connect(mCallsWindow, &QQuickWindow::activeChanged, this, &App::handleAppActivity);
	}
	if (!callGui.isNull() && callGui.isValid()) mCallsWindow->setProperty("call", callGui);
	return mCallsWindow;
}

void App::setCallsWindowProperty(const char *id, QVariant property) {
	if (mCallsWindow) mCallsWindow->setProperty(id, property);
}

void App::closeCallsWindow() {
	if (mCallsWindow && mCallList && !mCallList->getHaveCall()) {
		mCallsWindow->close();
		mCallsWindow->deleteLater();
		mCallsWindow = nullptr;
	}
}

QQuickWindow *App::getMainWindow() const {
	return mMainWindow;
}

void App::setMainWindow(QQuickWindow *data) {
	if (mMainWindow) disconnect(mMainWindow, &QQuickWindow::activeChanged, this, nullptr);
	if (mMainWindow != data) {
		mMainWindow = data;
		connect(mMainWindow, &QQuickWindow::activeChanged, this, &App::handleAppActivity);
		handleAppActivity();
		emit mainWindowChanged();
	}
}

QQuickWindow *App::getLastActiveWindow() const {
	return mLastActiveWindow;
}
void App::setLastActiveWindow(QQuickWindow *data) {
	if (mLastActiveWindow != data) {
		mLastActiveWindow = data;
	}
}

QSharedPointer<AccountList> App::getAccountList() const {
	return mAccountList;
}

void App::setAccountList(QSharedPointer<AccountList> data) {
	if (mAccountList != data) {
		mAccountList = data;
		emit accountsChanged();
	}
}

AccountList *App::getAccounts() const {
	return mAccountList.get();
}

QSharedPointer<ConferenceInfoList> App::getConferenceInfoList() const {
	return mConferenceInfoList;
}
void App::setConferenceInfoList(QSharedPointer<ConferenceInfoList> data) {
	if (mConferenceInfoList != data) {
		mConferenceInfoList = data;
		emit conferenceInfosChanged();
	}
}

QSharedPointer<CallHistoryList> App::getCallHistoryList() const {
	return mCallHistoryList;
}
void App::setCallHistoryList(QSharedPointer<CallHistoryList> data) {
	if (mCallHistoryList != data) {
		mCallHistoryList = data;
		emit callHistoryChanged();
	}
}

QSharedPointer<ChatList> App::getChatList() const {
	return mChatList;
}

ChatList *App::getChats() const {
	return mChatList.get();
}

void App::setChatList(QSharedPointer<ChatList> data) {
	if (mChatList != data) {
		mChatList = data;
		emit chatsChanged();
	}
}

QSharedPointer<CallList> App::getCallList() const {
	return mCallList;
}

void App::setCallList(QSharedPointer<CallList> data) {
	if (mCallList != data) {
		mCallList = data;
		emit callsChanged();
	}
}

CallList *App::getCalls() const {
	return mCallList.get();
}

QSharedPointer<SettingsCore> App::getSettings() const {
	return mSettings;
}

void App::onExitOnCloseChanged() {
	setSysTrayIcon(); // Restore button depends from this option
	if (mSettings) setQuitOnLastWindowClosed(mSettings->getExitOnClose());
	if (mSettings) setAutoStart(mSettings->getAutoStart());
}

void App::onAuthenticationRequested(const std::shared_ptr<linphone::Core> &core,
                                    const std::shared_ptr<linphone::AuthInfo> &authInfo,
                                    linphone::AuthMethod method) {
	bool authInfoIsInAccounts = false;
	if (authInfo) {
		for (auto &account : core->getAccountList()) {
			if (!account) continue;
			auto accountAuthInfo = account->findAuthInfo();
			if (accountAuthInfo) {
				if (authInfo->isEqualButAlgorithms(accountAuthInfo)) {
					authInfoIsInAccounts = true;
					break;
				}
			} else {
				auto identityAddress = account->getParams()->getIdentityAddress();
				if (!identityAddress) continue;
				if (authInfo->getUsername() == identityAddress->getUsername() &&
				    authInfo->getDomain() == identityAddress->getDomain()) {
					authInfoIsInAccounts = true;
					break;
				}
			}
		}
	}
	if (!authInfoIsInAccounts) return;
	mCoreModelConnection->invokeToCore([this, core, authInfo, method]() {
		auto window = App::getInstance()->getMainWindow();
		if (!window) {
			// Note: we can do connection with shared pointers because of SingleShotConnection
			connect(
			    this, &App::mainWindowChanged, this,
			    [this, core, authInfo, method]() { onAuthenticationRequested(core, authInfo, method); },
			    Qt::SingleShotConnection);
		} else {
			if (method == linphone::AuthMethod::HttpDigest) {
				lInfo() << log().arg("Received HttpDigest");
				auto username = Utils::coreStringToAppString(authInfo->getUsername());
				auto domain = Utils::coreStringToAppString(authInfo->getDomain());
				CallbackHelper *callback = new CallbackHelper();
				auto cb = [this, authInfo, core](QVariant vPassword) {
					mCoreModelConnection->invokeToModel([this, core, authInfo, vPassword] {
						QString password = vPassword.toString();
						mustBeInLinphoneThread("[App] reauthenticate");
						if (password.isEmpty()) {
							lDebug() << log().arg("ERROR : empty password");
						} else {
							lDebug() << log()
							                .arg("Reset password for %1")
							                .arg(Utils::coreStringToAppString(authInfo->getUsername()));
							authInfo->setPassword(Utils::appStringToCoreString(password));
							core->addAuthInfo(authInfo);
							core->refreshRegisters();
						}
					});
				};
				connect(callback, &CallbackHelper::cb, cb);
				QMetaObject::invokeMethod(window, "reauthenticateAccount", Qt::DirectConnection,
				                          Q_ARG(QVariant, username), Q_ARG(QVariant, domain),
				                          QVariant::fromValue(callback));
			}
		}
	});
}

#ifdef Q_OS_LINUX
QString App::getApplicationPath() const {
	const QString binPath(QCoreApplication::applicationFilePath());

	// Check if installation is done via Flatpak, AppImage, or classic package
	// in order to rewrite a correct exec path for autostart
	QString exec;
	qDebug() << "binpath=" << binPath;
	if (binPath.startsWith("/app")) { // Flatpak
		exec = QStringLiteral("flatpak run " APPLICATION_ID);
		qDebug() << "exec path autostart set flatpak=" << exec;
	} else if (binPath.startsWith("/tmp/.mount")) { // Appimage
		exec = QProcessEnvironment::systemEnvironment().value(QStringLiteral("APPIMAGE"));
		qDebug() << "exec path autostart set appimage=" << exec;
	} else { // classic package
		exec = binPath;
		qDebug() << "exec path autostart set classic package=" << exec;
	}
	return exec;
}

void App::exportDesktopFile() {
	QDir dir(ApplicationsDirectory);
	if (!dir.exists() && !dir.mkpath(ApplicationsDirectory)) {
		qWarning() << QStringLiteral("Unable to build applications dir path: `%1`.").arg(ApplicationsDirectory);
		return;
	}

	const QString confPath(ApplicationsDirectory + EXECUTABLE_NAME ".desktop");
	if (generateDesktopFile(confPath, true, false)) generateDesktopFile(confPath, false, false);
}

bool App::generateDesktopFile(const QString &confPath, bool remove, bool openInBackground) {
	qInfo() << QStringLiteral("Updating `%1`…").arg(confPath);
	QFile file(confPath);

	if (remove) {
		if (file.exists() && !file.remove()) {
			qWarning() << QLatin1String("Unable to remove autostart file: `" EXECUTABLE_NAME ".desktop`.");
			return false;
		}
		return true;
	}

	if (!file.open(QFile::WriteOnly)) {
		qWarning() << "Unable to open autostart file: `" EXECUTABLE_NAME ".desktop`.";
		return false;
	}

	QString exec = getApplicationPath();

	QDir dir;
	QString iconPath;
	bool haveIcon = false;
	if (!dir.mkpath(IconsDirectory)) // Scalable icons folder may be created
		qWarning() << "Cannot create scalable icon path at " << IconsDirectory;
	else {
		iconPath = IconsDirectory + EXECUTABLE_NAME + ".svg";
		QFile icon(Constants::WindowIconPath);
		if (!QFile(iconPath).exists()) { // Keep old icon but copy if it doesn't exist
			haveIcon = icon.copy(iconPath);
			if (!haveIcon) qWarning() << "Couldn't copy icon svg into " << iconPath;
			else { // Update permissions
				QFile icon(iconPath);
				icon.setPermissions(icon.permissions() | QFileDevice::WriteOwner);
			}
		} else {
			qInfo() << "Icon already exists in " << IconsDirectory << ". It is not replaced.";
			haveIcon = true;
		}
	}

	QTextStream(&file) << QString("[Desktop Entry]\n"
	                              "Name=" APPLICATION_NAME "\n"
	                              "GenericName=SIP Phone\n"
	                              "Comment=" APPLICATION_DESCRIPTION "\n"
	                              "Type=Application\n")
	                   << (openInBackground ? "Exec=" + exec + " --minimized %u\n" : "Exec=" + exec + " %u\n")
	                   << (haveIcon ? "Icon=" + iconPath + "\n" : "Icon=" EXECUTABLE_NAME "\n")
	                   << "Terminal=false\n"
	                      "Categories=Network;Telephony;\n"
	                      "MimeType=x-scheme-handler/sip-" EXECUTABLE_NAME ";x-scheme-handler/sips-" EXECUTABLE_NAME
	                      ";x-scheme-handler/" EXECUTABLE_NAME "-sip;x-scheme-handler/" EXECUTABLE_NAME
	                      "-sips;x-scheme-handler/sip;x-scheme-handler/sips;x-scheme-handler/tel;x-scheme-handler/"
	                      "callto;x-scheme-handler/" EXECUTABLE_NAME "-config;\n"
	                      "X-PulseAudio-Properties=media.role=phone\n";

	return true;
}
#elif defined(Q_OS_MACOS)
// On MAC, URI handlers call the application with no arguments and pass them in event loop.
bool App::event(QEvent *event) {
	if (event->type() == QEvent::FileOpen) {
		const QString url = static_cast<QFileOpenEvent *>(event)->url().toString();
		if (isSecondary()) {
			sendMessage(url.toLocal8Bit(), -1);
			::exit(EXIT_SUCCESS);
		}
		receivedMessage(0, url.toLocal8Bit());
	} else if (event->type() == QEvent::ApplicationStateChange) {
		auto state = static_cast<QApplicationStateChangeEvent *>(event);
		if (state->applicationState() == Qt::ApplicationActive) Utils::smartShowWindow(getLastActiveWindow());
	} else if (event->type() == QEvent::ApplicationActivate) {
		for (int i = 0; i < getAccountList()->rowCount(); ++i) {
			auto accountCore = getAccountList()->getAt<AccountCore>(i);
			handleAccountActivity(accountCore);
		}
	} else if (event->type() == QEvent::ApplicationDeactivate) {
		for (int i = 0; i < getAccountList()->rowCount(); ++i) {
			auto accountCore = getAccountList()->getAt<AccountCore>(i);
			handleAccountActivity(accountCore);
		}
	}

	return SingleApplication::event(event);
}

#endif

//-----------------------------------------------------------
//		System tray
//-----------------------------------------------------------

void App::setSysTrayIcon() {
	qDebug() << "setSysTrayIcon";
	QQuickWindow *root = getMainWindow();
	QSystemTrayIcon *systemTrayIcon =
	    (mSystemTrayIcon ? mSystemTrayIcon
	                     : new QSystemTrayIcon(nullptr)); // Workaround : QSystemTrayIcon cannot be deleted because
	                                                      // of setContextMenu (indirectly)

	// trayIcon: Right click actions.
	QAction *restoreAction = nullptr;
	if (mSettings && !mSettings->getExitOnClose()) {
		restoreAction = new QAction(root);
		auto setRestoreActionText = [restoreAction](bool visible) {
			//: "Cacher"
			//: "Afficher"
			restoreAction->setText(visible ? tr("hide_action") : tr("show_action"));
		};
		setRestoreActionText(root ? root->isVisible() : false);
		connect(root, &QWindow::visibleChanged, restoreAction, setRestoreActionText);

		root->connect(restoreAction, &QAction::triggered, this, [this, restoreAction](bool checked) {
			auto mainWindow = getMainWindow();
			if (mainWindow->isVisible()) {
				mainWindow->close();
			} else {
				mainWindow->show();
			}
		});
	}
	//: "Quitter"
	QAction *quitAction = new QAction(tr("quit_action"), root);
	root->connect(quitAction, &QAction::triggered, this, &App::quit);

	//: "Mark all as read"
	QAction *markAllReadAction = createMarkAsReadAction(root);

	// trayIcon: Left click actions.
	QMenu *menu = mSystemTrayIcon ? mSystemTrayIcon->contextMenu() : new QMenu();
	menu->clear();
	menu->setTitle(APPLICATION_NAME);
	// Build trayIcon menu.
	if (restoreAction) {
		menu->addAction(restoreAction);
		menu->addSeparator();
	}
	menu->addAction(markAllReadAction);
	//: Check for update
	if (mSettings->isCheckForUpdateAvailable()) {
		QAction *checkForUpdateAction = new QAction(tr("check_for_update"), root);
		root->connect(checkForUpdateAction, &QAction::triggered, this, [this] { checkForUpdate(true); });
		menu->addAction(checkForUpdateAction);
	}
	menu->addAction(quitAction);
	if (!mSystemTrayIcon) {
		systemTrayIcon->setContextMenu(menu); // This is a Qt bug. We cannot call setContextMenu more than once. So
		                                      // we have to keep an instance of the menu.
		connect(systemTrayIcon, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
			// Left-Click and Double Left-Click
			if (reason == QSystemTrayIcon::Trigger || reason == QSystemTrayIcon::DoubleClick) {
				auto mainWindow = getMainWindow();
				if (mainWindow) mainWindow->show();
			}
		});
	}
	systemTrayIcon->setIcon(QIcon(Constants::WindowIconPath));
	systemTrayIcon->setToolTip(APPLICATION_NAME);
	systemTrayIcon->show();
	if (!mSystemTrayIcon) mSystemTrayIcon = systemTrayIcon;
	if (!QSystemTrayIcon::isSystemTrayAvailable()) qInfo() << "System tray is not available";
}

//-----------------------------------------------------------
//		MacOS dock menu actions
//-----------------------------------------------------------

#ifdef __APPLE__
/**
 * Set more actions to the MacOS Dock actions
 * WARNING: call this function only on macOS
 */
void App::setMacOSDockActions() {
	QMenu *menu = new QMenu();
	QQuickWindow *root = getMainWindow();
	QAction *markAllReadAction = createMarkAsReadAction(root);
	menu->addAction(markAllReadAction);
	menu->setAsDockMenu();
}
#endif

//-----------------------------------------------------------
//		Locale TODO - App only in French now.
//-----------------------------------------------------------

void App::setLocale(QString configLocale) {
	if (!configLocale.isEmpty()) mLocale = QLocale(configLocale);
	else mLocale = QLocale(QLocale::system().name());
	emit localeChanged();
}

QLocale App::getLocale() {
	return mLocale;
}

QString App::getLocaleAsString() {
	return mLocale.name();
}

//-----------------------------------------------------------
//		Version infos.
//-----------------------------------------------------------

//: "Inconnue"
QString App::getShortApplicationVersion() {
#ifdef LINPHONEAPP_SHORT_VERSION
	return QStringLiteral(LINPHONEAPP_SHORT_VERSION);
#else
	return tr('unknown');
#endif
}

QString App::getGitBranchName() {
#ifdef GIT_BRANCH_NAME
	return QStringLiteral(GIT_BRANCH_NAME);
#else
	return tr('unknown');
#endif
}

QString App::getSdkVersion() {
#ifdef LINPHONESDK_VERSION
	return QStringLiteral(LINPHONESDK_VERSION);
#else
	return tr('unknown');
#endif
}

QString App::getQtVersion() const {
	return qVersion();
}

void App::checkForUpdate(bool requestedByUser) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	if (CoreModel::getInstance() && mCoreModelConnection) {
		mCoreModelConnection->invokeToModel([this, requestedByUser] {
			mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
			CoreModel::getInstance()->checkForUpdate(Utils::appStringToCoreString(applicationVersion()),
			                                         requestedByUser);
		});
	}
}

ChatGui *App::getCurrentChat() const {
	return mCurrentChat;
}

void App::setCurrentChat(ChatGui *chat) {
	if (chat != mCurrentChat) {
		mCurrentChat = chat;
		emit currentChatChanged();
	}
}

AccountGui *App::getCurrentAccount() const {
	return mAccountList ? mAccountList->getDefaultAccount() : nullptr;
}

float App::getScreenRatio() const {
	return mScreenRatio;
}

void App::setScreenRatio(float ratio) {
	mScreenRatio = ratio;
}

QAction *App::createMarkAsReadAction(QQuickWindow *window) {
	QAction *markAllReadAction = new QAction(tr("mark_all_read_action"), window);
	window->connect(markAllReadAction, &QAction::triggered, this, [this] {
		lDebug() << "Mark all as read";
		emit mAccountList->lResetMissedCalls();
		emit mAccountList->lResetUnreadMessages();
		mCoreModelConnection->invokeToModel([this]() { CoreModel::getInstance()->unreadNotificationsChanged(); });
	});
	return markAllReadAction;
}
