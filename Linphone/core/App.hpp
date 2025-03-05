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

#include <QCommandLineParser>
#include <QQmlApplicationEngine>
#include <QSharedPointer>

#include "core/account/AccountProxy.hpp"
#include "core/call/CallProxy.hpp"
#include "core/setting/SettingsCore.hpp"
#include "core/singleapplication/singleapplication.h"
#include "model/cli/CliModel.hpp"
#include "model/core/CoreModel.hpp"
#include "tool/AbstractObject.hpp"

class CallGui;
class Thread;
class Notifier;
class QQuickWindow;
class QSystemTrayIcon;
class DefaultTranslatorCore;

class App : public SingleApplication, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(bool coreStarted READ getCoreStarted WRITE setCoreStarted NOTIFY coreStartedChanged)
	Q_PROPERTY(AccountList *accounts READ getAccounts NOTIFY accountsChanged)
	Q_PROPERTY(CallList *calls READ getCalls NOTIFY callsChanged)
	Q_PROPERTY(QString shortApplicationVersion READ getShortApplicationVersion CONSTANT)
	Q_PROPERTY(QString gitBranchName READ getGitBranchName CONSTANT)
	Q_PROPERTY(QString sdkVersion READ getSdkVersion CONSTANT)

public:
	App(int &argc, char *argv[]);
	~App();
	void setSelf(QSharedPointer<App>(me));
	static App *getInstance();
	static QThread *getLinphoneThread();
	Notifier *getNotifier() const;

	// App::postModelAsync(<lambda>) => run lambda in model thread and continue.
	// App::postModelSync(<lambda>) => run lambda in current thread and block connection.
	template <typename Func, typename... Args>
	static auto postModelAsync(Func &&callable, Args &&...args) {
		QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable, args...);
	}
	template <typename Func>
	static auto postModelAsync(Func &&callable) {
		QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable);
	}
	template <typename Func, typename... Args>
	static auto postCoreAsync(Func &&callable, Args &&...args) {
		QMetaObject::invokeMethod(App::getInstance(), callable, args...);
	}
	template <typename Func>
	static auto postCoreAsync(Func &&callable) {
		QMetaObject::invokeMethod(App::getInstance(), callable);
	}
	template <typename Func, typename... Args>
	static auto postCoreSync(Func &&callable, Args &&...args) {
		if (QThread::currentThread() == CoreModel::getInstance()->thread()) {
			bool end = false;
			postCoreAsync([&end, callable, args...]() mutable {
				QMetaObject::invokeMethod(App::getInstance(), callable, args..., Qt::DirectConnection);
				end = true;
			});
			while (!end)
				qApp->processEvents();
		} else {
			QMetaObject::invokeMethod(App::getInstance(), callable, Qt::DirectConnection);
		}
	}
	template <typename Func, typename... Args>
	static auto postModelSync(Func &&callable, Args &&...args) {
		if (QThread::currentThread() != CoreModel::getInstance()->thread()) {
			bool end = false;
			postModelAsync([&end, callable, args...]() mutable {
				QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable, args..., Qt::DirectConnection);
				end = true;
			});
			while (!end)
				qApp->processEvents();
		} else {
			QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable, Qt::DirectConnection);
		}
	}

	template <typename Func, typename... Args>
	static auto postModelBlock(Func &&callable, Args &&...args) {
		if (QThread::currentThread() != CoreModel::getInstance()->thread()) {
			QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable, args..., Qt::BlockingQueuedConnection);
		} else {
			QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable, Qt::DirectConnection);
		}
	}

	void clean();
	void init();
	void initCore();
	void initLocale();
	void initCppInterfaces();
	void initFonts();
	void restart();
	bool autoStartEnabled();
	void setSysTrayIcon();
	QLocale getLocale();

	void onLoggerInitialized();
	void sendCommand();

	bool getCoreStarted() const;
	void setCoreStarted(bool started);

	QQuickWindow *getCallsWindow(QVariant callGui = QVariant());
	void setCallsWindowProperty(const char *id, QVariant property);
	void closeCallsWindow();

	QQuickWindow *getMainWindow() const;
	void setMainWindow(QQuickWindow *data);
	QQuickWindow *getLastActiveWindow() const;
	void setLastActiveWindow(QQuickWindow *data);

	QSharedPointer<AccountList> getAccountList() const;
	void setAccountList(QSharedPointer<AccountList> data);
	Q_INVOKABLE AccountList *getAccounts() const;

	QSharedPointer<CallList> getCallList() const;
	void setCallList(QSharedPointer<CallList> data);
	Q_INVOKABLE CallList *getCalls() const;
	QSharedPointer<SettingsCore> getSettings() const;

	void onExitOnCloseChanged(); // Can be used for UniqueConnection
	void onAuthenticationRequested(const std::shared_ptr<linphone::Core> &core,
	                               const std::shared_ptr<linphone::AuthInfo> &authInfo,
	                               linphone::AuthMethod method);

	QString getShortApplicationVersion();
	QString getGitBranchName();
	QString getSdkVersion();

#ifdef Q_OS_LINUX
	Q_INVOKABLE void exportDesktopFile();

	QString getApplicationPath() const;
	bool generateDesktopFile(const QString &confPath, bool remove, bool openInBackground);
#elif defined(Q_OS_MACOS)
	bool event(QEvent *event) override;
#endif

	QQmlApplicationEngine *mEngine = nullptr;
	bool notify(QObject *receiver, QEvent *event) override;

	enum class StatusCode { gRestartCode = 1000, gDeleteDataCode = 1001 };

signals:
	void mainWindowChanged();
	void coreStartedChanged(bool coreStarted);
	void accountsChanged();
	void callsChanged();
	void currentDateChanged();
	// void executeCommand(QString command);

private:
	void createCommandParser();
	void setAutoStart(bool enabled);
	void setLocale(QString configLocale);

	QCommandLineParser *mParser = nullptr;
	Thread *mLinphoneThread = nullptr;
	Notifier *mNotifier = nullptr;
	QSystemTrayIcon *mSystemTrayIcon = nullptr;
	QQuickWindow *mMainWindow = nullptr;
	QQuickWindow *mCallsWindow = nullptr;
	QQuickWindow *mLastActiveWindow = nullptr;
	QSharedPointer<SettingsCore> mSettings;
	QSharedPointer<AccountList> mAccountList;
	QSharedPointer<CallList> mCallList;
	QSharedPointer<SafeConnection<App, CoreModel>> mCoreModelConnection;
	QSharedPointer<SafeConnection<App, CliModel>> mCliModelConnection;
	bool mAutoStart = false;
	bool mCoreStarted = false;
	QLocale mLocale = QLocale::system();
	DefaultTranslatorCore *mTranslatorCore = nullptr;
	DefaultTranslatorCore *mDefaultTranslatorCore = nullptr;
	QTimer mDateUpdateTimer;
	QDate mCurrentDate;

	DECLARE_ABSTRACT_OBJECT
};
