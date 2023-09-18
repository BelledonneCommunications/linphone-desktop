/*
 * Copyright (c) 2010-2022 Belledonne Communications SARL.
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

#ifndef VFS_UTILS_H_
#define VFS_UTILS_H_

#include "config.h"
#include <QObject>
#ifdef QTKEYCHAIN_USE_BUILD_INTERFACE
#include <keychain.h>
#elif defined(QTKEYCHAIN_TARGET_NAME)
#define KEYCHAIN_HEADER <QTKEYCHAIN_TARGET_NAME/keychain.h>
#include KEYCHAIN_HEADER
#else
#include <EQt5Keychain/keychain.h>
#endif
#include <QSettings>

// =============================================================================

class VfsUtils : public QObject {
	Q_OBJECT

public:
	VfsUtils(QObject *parent = Q_NULLPTR);
	
	Q_INVOKABLE void deleteKey(const QString& key);	// Delete a key and send error() or keyDeleted()
	Q_INVOKABLE void readKey(const QString& key);	// Read a key, send error() or keyStored()
	Q_INVOKABLE void writeKey(const QString& key, const QString& value); // Write a key and send error() or keyWritten()
	
	
	void newEncryptionKeyAsync();	// Generate a key, store it and update SDK. Wait for keyWritten() or error().
	
	static bool newEncryptionKey(); // Generate a key, store it and update SDK.
	static bool updateSDKWithKey(int argc, char *argv[]);	// Can be calle outside application.
	static bool updateSDKWithKey(QSettings * settings);	// Update SDK if key exists. Return true if encrypted.
	static bool updateSDKWithKey();// Need it to pass QSettings
	static void updateSDKWithKey(const QString& key);// SDK->setVfsEncryption(key) 
	
	QString getApplicationVfsEncryptionKey() const;// Get the key in store keys for VFS encryyption
	
	bool needToDeleteUserData() const;
	void needToDeleteUserData(const bool& need);
	
signals:
	void keyDeleted(const QString& key);
	void keyRead(const QString& key, const QString& value);
	void keyWritten(const QString& key);
	
	void error(const QString& errorText);
	
private:
	QKeychain::ReadPasswordJob   mReadCredentialJob;
	QKeychain::WritePasswordJob  mWriteCredentialJob;
	QKeychain::DeletePasswordJob mDeleteCredentialJob;
	
	bool mNeedToDeleteUserData = false;
	bool mVfsEncrypted = false;
};

#endif
