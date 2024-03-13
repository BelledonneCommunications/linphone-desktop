// /*
//  * Copyright (c) 2010-2024 Belledonne Communications SARL.
//  *
//  * This file is part of linphone-desktop
//  * (see https://www.linphone.org).
//  *
//  * This program is free software: you can redistribute it and/or modify
//  * it under the terms of the GNU General Public License as published by
//  * the Free Software Foundation, either version 3 of the License, or
//  * (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program. If not, see <http://www.gnu.org/licenses/>.
//  */
// // This object is defferent from usual Core. It set internal data from directly from GUI.
// // Values are saved on request.
// // This allow revert feature.

#ifndef VARIANT_LIST_H_
#define VARIANT_LIST_H_

#include "core/proxy/AbstractListProxy.hpp"
#include "tool/AbstractObject.hpp"

// ///////////////////////////// ADDRESS LIST /////////////////////////////

class VariantList : public AbstractListProxy<QVariant>, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QList<QVariant> model WRITE setModel NOTIFY modelChanged)
public:
	VariantList(QObject *parent = Q_NULLPTR);
	VariantList(QList<QVariant> list, QObject *parent = Q_NULLPTR);
	~VariantList();

	void setModel(QList<QVariant> list);

	void replace(int index, QVariant newValue);

	virtual int rowCount(const QModelIndex &parent = QModelIndex()) const override;

	virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

signals:
	void modelChanged();

private:
	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(VariantList *)

#endif
