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

#ifndef VARIANT_OBJECT_H_
#define VARIANT_OBJECT_H_

#include "tool/AbstractObject.hpp"

#include <QObject>
#include <QSharedPointer>
#include <QVariant>

#include "SafeObject.hpp"
#include "tool/thread/SafeConnection.hpp"

class CoreModel;

class VariantObject : public QObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QVariant value READ getValue NOTIFY valueChanged)
public:
	VariantObject(QObject *parent = nullptr);
	VariantObject(QVariant defaultValue, QObject *parent = nullptr);
	~VariantObject();

	template <typename Func, typename... Args>
	void makeRequest(Func &&callable, Args &&...args) {
		mConnection->makeConnectToCore(&SafeObject::requestValue, [this, callable, args...]() {
			mConnection->invokeToModel([this, callable, args...]() { mModelObject->setValue(callable(args...)); });
		});
	}
	template <typename Sender, typename SenderClass>
	void makeUpdate(Sender sender, SenderClass signal) {
		mConnection->makeConnectToModel(
		    sender, signal, [this]() { mConnection->invokeToCore([this]() { mCoreObject->requestValue(); }); });
	}

	QVariant getValue() const;
	void requestValue();

	QSharedPointer<SafeObject> mCoreObject, mModelObject;
	QSharedPointer<SafeConnection<SafeObject, SafeObject>> mConnection;
signals:
	void valueChanged(QVariant value);

private:
	DECLARE_ABSTRACT_OBJECT
};

#endif
