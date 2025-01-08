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

#include "VariantObject.hpp"

#include <QDebug>
#include <QTest>

#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(VariantObject)
VariantObject::VariantObject(QString name, QObject *parent) : VariantObject(name, QVariant()) {
}
VariantObject::VariantObject(QString name, QVariant defaultValue, QObject *parent) {
	mName = name;
	mCoreObject = QSharedPointer<SafeObject>(new SafeObject(defaultValue), &QObject::deleteLater);
	mModelObject = QSharedPointer<SafeObject>(new SafeObject(), &QObject::deleteLater);
	mModelObject->moveToThread(CoreModel::getInstance()->thread());

	App::getInstance()->mEngine->setObjectOwnership(mCoreObject.get(), QQmlEngine::CppOwnership);
	App::getInstance()->mEngine->setObjectOwnership(mModelObject.get(), QQmlEngine::CppOwnership);

	mConnection = QSharedPointer<SafeConnection<SafeObject, SafeObject>>(
	    new SafeConnection<SafeObject, SafeObject>(mCoreObject, mModelObject), &QObject::deleteLater);

	mConnection->makeConnectToCore(&SafeObject::setValue, [this, d = mName](QVariant value) {
		mConnection->invokeToModel([this, value, d]() {
			if (mModelObject) mModelObject->onSetValue(value);
		});
	});
	mConnection->makeConnectToModel(&SafeObject::setValue, [this, d = mName, coreObject = mCoreObject](QVariant value) {
		// Note: do not use member because 'this' is managed by GUI and can be deleted.
		mConnection->invokeToCore([this, d, coreObject, value]() {
			if (coreObject) coreObject->onSetValue(value);
		});
	});
	mConnection->makeConnectToModel(&SafeObject::valueChanged, [this](QVariant value) {
		mConnection->invokeToCore([this, value]() { mCoreObject->valueChanged(value); });
	});
	connect(mCoreObject.get(), &SafeObject::valueChanged, this, &VariantObject::valueChanged);
}

VariantObject::~VariantObject() {
}

QVariant VariantObject::getValue() const {
	return mCoreObject->getValue();
}
void VariantObject::setDefaultValue(QVariant value) {
	mCoreObject->setDefaultValue(value);
}
void VariantObject::requestValue() {
	emit mCoreObject->requestValue();
}
