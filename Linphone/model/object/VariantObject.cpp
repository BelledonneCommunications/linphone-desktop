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

	mConnection = SafeConnection<SafeObject, SafeObject>::create(mCoreObject, mModelObject);

	// Note: do not use member because 'this' is managed by GUI and can be deleted. Objects scope should have the same
	// as connections so it should be fine to use the object directly.
	mConnection->makeConnectToCore(&SafeObject::setValue,
	                               [this, d = mName, modelObject = mModelObject.get()](QVariant value) {
		                               if (modelObject && !modelObject->mDeleted)
			                               mConnection->invokeToModel([this, value, d, modelObject]() {
				                               if (modelObject && !modelObject->mDeleted)
					                               modelObject->onSetValue(value);
			                               });
	                               });
	mConnection->makeConnectToModel(&SafeObject::setValue,
	                                [this, d = mName, coreObject = mCoreObject.get()](QVariant value) {
		                                if (coreObject && !coreObject->mDeleted)
			                                mConnection->invokeToCore([this, d, coreObject, value]() {
				                                if (coreObject && !coreObject->mDeleted) coreObject->onSetValue(value);
			                                });
	                                });
	mConnection->makeConnectToModel(&SafeObject::valueChanged, [this, coreObject = mCoreObject.get()](QVariant value) {
		if (coreObject && !coreObject->mDeleted)
			mConnection->invokeToCore([this, value, coreObject]() {
				if (coreObject && !coreObject->mDeleted) coreObject->valueChanged(value);
			});
	});
	connect(mCoreObject.get(), &SafeObject::valueChanged, this, &VariantObject::valueChanged);
}

VariantObject::~VariantObject() {
	mCoreObject->mDeleted = true;
	mModelObject->mDeleted = true;
}

QVariant VariantObject::getValue() const {
	return mCoreObject->getValue();
}
void VariantObject::setDefaultValue(QVariant value) {
	mCoreObject->setDefaultValue(value);
}
void VariantObject::requestValue() {
	if (mCoreObject) emit mCoreObject->requestValue();
}
