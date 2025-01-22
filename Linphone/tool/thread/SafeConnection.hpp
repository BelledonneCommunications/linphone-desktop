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
#include "model/core/CoreModel.hpp"
#include "tool/Utils.hpp"
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

template <class A, class B>
class SafeConnection : public QObject {
	// Use create functions.
protected:
	SafeConnection(QSharedPointer<A> a, std::shared_ptr<B> b)
	    : mCore(a), mModel(b), mCoreObject(a.get()), mModelObject(b.get()) {
	}
	SafeConnection(QSharedPointer<A> a, QSharedPointer<B> b)
	    : mCore(a), mModel(b), mCoreObject(a.get()), mModelObject(b.get()) {
	}
	~SafeConnection() {
		mLocker.lock();
		if (mModel.mCountRef != 0)
			QTimer::singleShot(1000, mModel.get(), []() {
				lCritical() << "[SafeConnection] Destroyed 1s ago but a Model is still in memory";
			});
		if (mCore.mCountRef != 0)
			QTimer::singleShot(1000, mCore.get(), []() {
				lCritical() << "[SafeConnection] Destroyed 1s ago but a Core is still in memory";
			});
		mLocker.unlock();
	}
	void setSelf(QSharedPointer<SafeConnection> me) {
		mSelf = me;
	}

public:
	static QSharedPointer<SafeConnection> create(QSharedPointer<A> a, std::shared_ptr<B> b) {
		QSharedPointer<SafeConnection> me =
		    QSharedPointer<SafeConnection<A, B>>(new SafeConnection<A, B>(a, b), &QObject::deleteLater);
		me->setSelf(me);
		return me;
	}
	static QSharedPointer<SafeConnection> create(QSharedPointer<A> a, QSharedPointer<B> b) {
		QSharedPointer<SafeConnection> me =
		    QSharedPointer<SafeConnection<A, B>>(new SafeConnection<A, B>(a, b), &QObject::deleteLater);
		me->setSelf(me);
		return me;
	}

	SafeSharedPointer<A> mCore;
	SafeSharedPointer<B> mModel;
	QMutex mLocker;
	QWeakPointer<SafeConnection> mSelf;

	template <typename Func1, typename Func2>
	inline QMetaObject::Connection makeConnectToModel(Func1 signal, Func2 slot) {
		return connect(mModelObject, signal, mCoreObject, slot, Qt::DirectConnection);
	}
	template <typename Sender, typename Func1, typename Func2>
	inline QMetaObject::Connection makeConnectToModel(Sender sender, Func1 signal, Func2 slot) {
		return connect(sender, signal, mCoreObject, slot, Qt::DirectConnection);
	}
	template <typename Func1, typename Func2>
	inline QMetaObject::Connection makeConnectToCore(Func1 signal, Func2 slot) {
		return connect(mCoreObject, signal, mModelObject, slot, Qt::DirectConnection);
	}

	inline void disconnect() {
		if (!tryLock()) // To avoid disconnections while being in call.
			return;     //  Return to avoid to disconnect other connections than the pair.
		QObject::disconnect(mModelObject, nullptr, mCoreObject, nullptr);
		QObject::disconnect(mCoreObject, nullptr, mModelObject, nullptr);
		unlock();
	}

	template <typename Func, typename... Args>
	void invokeToModel(Func &&callable, Args &&...args) {
		if (!tryLock()) return;
		auto connection = mSelf.lock();
		QMetaObject::invokeMethod(mModel.get(), [&, connection, callable, args...]() { // Is async
			QMetaObject::invokeMethod(mModel.get(), callable, args...);                // Is Sync
			unlock();
		});
	}

	// Will running call in Core
	template <typename Func, typename... Args>
	void invokeToCore(Func &&callable, Args &&...args) {
		if (!tryLock()) return;
		auto connection = mSelf.lock();
		QMetaObject::invokeMethod(mCore.get(), [&, connection, callable, args...]() { // Is async
			QMetaObject::invokeMethod(mCore.get(), callable, args...);                // Is Sync
			unlock();
		});
	}

	bool tryLock() {
		mLocker.lock();
		auto coreLocked = mCore.lock();
		auto modelLocked = mModel.lock();
		if (!coreLocked || !modelLocked) {
			if (coreLocked) mCore.unlock();
			if (modelLocked) mModel.unlock();
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

protected:
	A *mCoreObject = nullptr;
	B *mModelObject = nullptr; // Use only for makeConnects
};

#endif
