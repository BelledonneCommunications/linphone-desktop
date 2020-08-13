/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef CONTACTS_IMPORTER_MODEL_H_
#define CONTACTS_IMPORTER_MODEL_H_

#include <QObject>
#include <QVariantMap>

// =============================================================================

class ContactsImporterDataAPI;

class ContactsImporterModel : public QObject {
	Q_OBJECT;

	Q_PROPERTY(QVariantMap fields READ getFields WRITE setFields NOTIFY fieldsChanged);
	Q_PROPERTY(int identity READ getIdentity WRITE setIdentity NOTIFY identityChanged);

public:
	ContactsImporterModel (ContactsImporterDataAPI * data, QObject *parent = nullptr);

	void setDataAPI(ContactsImporterDataAPI *data);
	bool isUsable();

	QVariantMap getFields();
	void setFields(const QVariantMap &pFields);

	
	int getIdentity()const;
	void setIdentity(const int &pIdentity);
	
	void loadConfiguration();
	Q_INVOKABLE void importContacts();

public slots:
	void parsedContacts(QVector<QMultiMap<QString, QString> > contacts);
	void updateInputs(const QVariantMap &inputs);

signals:
	void fieldsChanged (QVariantMap fields);
	void identityChanged(int identity);
	void errorMessage(const QString& message);
	void statusMessage(const QString& message);
	
private:
	int mIdentity;
	ContactsImporterDataAPI *mData;
};

Q_DECLARE_METATYPE(ContactsImporterModel *);

#endif // CONTACTS_IMPORTER_MODEL_H_
