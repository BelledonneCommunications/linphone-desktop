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
#include <QVariant>

// Store the VariantObject on a propery and use value.
// Do not use direcly teh value like VariantObject.value : in this case if value change, VariantObject will be
// reevaluated.

class VariantObject : public QObject, public AbstractObject {
	Q_OBJECT
public:
	Q_PROPERTY(QVariant value READ getValue WRITE setValue NOTIFY valueChanged)

	VariantObject(QObject *parent = nullptr);
	VariantObject(QVariant value, QObject *parent = nullptr);
	~VariantObject();

	QVariant getValue() const;
	void setValue(QVariant value);

	VariantObject *mCoreObject; // Ensure to use DeleteLater() after updating value

signals:
	void valueChanged(QVariant value);
	void updateValue(QVariant value);

private:
	QVariant mValue;
	DECLARE_ABSTRACT_OBJECT
};

#endif
