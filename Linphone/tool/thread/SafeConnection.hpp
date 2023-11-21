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

#ifndef SAFE_CONNECTION_H_
#define SAFE_CONNECTION_H_

#include "SafeSharedPointer.hpp"
#include <QMutex>
#include <QObject>

// Use this class to protect sender/receiver from being deleted while running a
// signal/call

/*
 * ObjectGui : mainAcces for GUI. Its memory is managed by JavaScript. It contains a QSharedPointer of ObjectCore.
 * ObjectCore : memory is CPP managed by QSharedPointer.
 * ObjectModel: memory is managed by shared pointers and is running on Model thread.
 *
 *  => ObjectGUI have QSharedPointer<ObjectCore>
 *  ObjectCore have std::shared_ptr<ObjectModel> and SafeConnection.
 *
 *  Need:
 *  - static QSharedPointer<ObjectCore> create(Args...args);  => It set self and moveToThread.
 *  - In GUI constructor : App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::JavaScriptOwnership);
 *  - In Core/model : App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
 *  - void setSelf(QSharedPointer<ObjectCore> me); => instantiate SafeConnection with :
 *  me.objectCast<QObject>(), std::dynamic_pointer_cast<QObject>(<Model_stored_in_ObjectCore>));
 *
 * Set connections in setSelf:
 * - From model
 * mSafeConnection->makeConnect( mModel.get()
 *      , &ObjectModel::signal, [this](params) {
 *           mSafeConnection->invokeToCore([this, params]() { this->slot(params); });
 *       });
 *
 *- From GUI
 * mSafeConnection->makeConnect(this, &ObjectCore::lSignal, [this](params) {
 *       mSafeConnection->invokeToModel([this, params]() { mModel->slot(params); });
 *   });
 *
 * - Direct call can be call with only invokeToModel/invokeToCore
 *
 *
 */

class SafeConnection : public QObject {
public:
	SafeConnection(SafeSharedPointer<QObject> a, SafeSharedPointer<QObject> b);
	~SafeConnection();
	SafeSharedPointer<QObject> mCore, mModel;
	QMutex mLocker;

	template <typename Func1, typename Func2>
	static inline QMetaObject::Connection makeConnect(const typename QtPrivate::FunctionPointer<Func1>::Object *sender,
	                                                  Func1 signal,
	                                                  Func2 slot,
	                                                  Qt::ConnectionType type = Qt::AutoConnection) {
		return connect(sender, signal, sender, slot, type);
	}

	template <typename Func, typename... Args>
	void invokeToModel(Func &&callable, Args &&...args) {
		if (!tryLock()) return;
		auto model = mModel.get();
		QMetaObject::invokeMethod(model, [&, model, callable, args...]() { // Is async
			QMetaObject::invokeMethod(model, callable, args...);           // Is Sync
			unlock();
		});
	}

	// Will running call in Core
	template <typename Func, typename... Args>
	void invokeToCore(Func &&callable, Args &&...args) {
		if (!tryLock()) return;
		QMetaObject::invokeMethod(mCore.get(), [&, callable, args...]() { // Is async
			QMetaObject::invokeMethod(mCore.get(), callable, args...);    // Is Sync
			unlock();
		});
	}

	bool tryLock() {
		mLocker.lock();
		if (!mCore.lock() || !mModel.lock()) { // Direct locking
			mCore.reset();
			mModel.reset();
			mLocker.unlock();
			return false;
		}
		mLocker.unlock();
		return true;
	}
	void unlock() {
		mLocker.lock();
		mCore.unlock();
		mModel.unlock();
		mLocker.unlock();
	}
};

#endif
