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

#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QSharedPointer>

#include "core/thread/Thread.hpp"
#include "core/singleapplication/singleapplication.h"
#include "model/core/CoreModel.hpp"

class App : public SingleApplication {
public:
	App(int &argc, char *argv[]);
	static App* getInstance();
	
// App::postModelAsync(<lambda>) => run lambda in model thread and continue.
// App::postModelSync(<lambda>) => run lambda in current thread and block connection.
	template<typename Func, typename... Args>
	static auto postModelAsync(Func&& callable, Args&& ...args) {
		QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable, args...);
	}
	template<typename Func>
	static auto postModelAsync(Func&& callable) {
		QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable);
	}
	template<typename Func>
	static auto postModelSync(Func&& callable) {
		QMetaObject::invokeMethod(CoreModel::getInstance().get(), callable
			, QThread::currentThread() != CoreModel::getInstance()->thread() ? Qt::BlockingQueuedConnection : Qt::DirectConnection);
	}

	void clean();
	void init();
	void initCppInterfaces();

	void onLoggerInitialized();

	QQmlApplicationEngine *mEngine = nullptr;
	
private: 
	void createCommandParser();
	
	QCommandLineParser *mParser = nullptr;
	Thread *mLinphoneThread = nullptr;
};
