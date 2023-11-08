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

DEFINE_ABSTRACT_OBJECT(VariantObject)

VariantObject::VariantObject(QObject *parent) {
	mustBeInMainThread(getClassName());
}

VariantObject::VariantObject(QVariant value, QObject *parent) : mValue(value) {
	mustBeInMainThread(getClassName());
	connect(this, &VariantObject::updateValue, this, &VariantObject::setValue);
	mCoreObject = new VariantObject();
	connect(mCoreObject, &VariantObject::valueChanged, this, &VariantObject::setValue);
	connect(mCoreObject, &VariantObject::valueChanged, mCoreObject, &QObject::deleteLater);
}

VariantObject::~VariantObject() {
	mustBeInMainThread("~" + getClassName());
}

QVariant VariantObject::getValue() const {
	mustBeInMainThread(QString(gClassName) + " : " + Q_FUNC_INFO);
	return mValue;
}

void VariantObject::setValue(QVariant value) {
	mustBeInMainThread(QString(gClassName) + " : " + Q_FUNC_INFO);
	if (value != mValue) {
		mValue = value;
		emit valueChanged(mValue);
	}
}
