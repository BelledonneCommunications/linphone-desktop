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

#ifndef DOWNLOADABLE_PAYLOAD_TYPE_CORE_H_
#define DOWNLOADABLE_PAYLOAD_TYPE_CORE_H_

#include "PayloadTypeCore.hpp"
#include "model/payload-type/DownloadablePayloadTypeModel.hpp"
#include "tool/AbstractObject.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class DownloadablePayloadTypeCore : public PayloadTypeCore {
	Q_OBJECT

public:
	Q_INVOKABLE void downloadAndExtract(bool isUpdate = false);
	bool shouldDownloadUpdate();

	static QSharedPointer<DownloadablePayloadTypeCore> create(PayloadTypeCore::Family family,
	                                                          const QString &mime,
	                                                          const QString &encoderDescription,
	                                                          const QString &downloadUrl,
	                                                          const QString &installName,
	                                                          const QString &checkSum);

	DownloadablePayloadTypeCore(PayloadTypeCore::Family family,
	                            const QString &mimeType,
	                            const QString &encoderDescription,
	                            const QString &downloadUrl,
	                            const QString &installName,
	                            const QString &checkSum);

	~DownloadablePayloadTypeCore();
	void setSelf(QSharedPointer<DownloadablePayloadTypeCore> me);

signals:
	void extractSuccess(QString filePath);
	void downloadError();
	void extractError();
	void installedChanged();
	void versionChanged();
	void loaded(bool success);

private:
	QString mDownloadUrl;
	QString mInstallName;
	QString mCheckSum;
	QString mVersion;

	std::shared_ptr<DownloadablePayloadTypeModel> mDownloadablePayloadTypeModel;
	QSharedPointer<SafeConnection<DownloadablePayloadTypeCore, DownloadablePayloadTypeModel>>
	    mDownloadablePayloadTypeModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(DownloadablePayloadTypeCore *)
#endif
