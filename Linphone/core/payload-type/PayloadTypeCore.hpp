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

#ifndef PAYLOAD_TYPE_CORE_H_
#define PAYLOAD_TYPE_CORE_H_

#include "model/payload-type/PayloadTypeModel.hpp"
#include "tool/AbstractObject.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class PayloadTypeCore : public QObject, public AbstractObject {
	Q_OBJECT

public:
	Q_ENUMS(Family)
	Q_PROPERTY(Family family MEMBER mFamily CONSTANT)
	DECLARE_CORE_MEMBER(int, clockRate, ClockRate)
	DECLARE_CORE_MEMBER(QString, recvFmtp, RecvFmtp)

	enum Family { Audio, Video, Text };

	static QSharedPointer<PayloadTypeCore> create(Family family,
	                                              const std::shared_ptr<linphone::PayloadType> &payloadType);

	PayloadTypeCore(Family family, const std::shared_ptr<linphone::PayloadType> &payloadType);
	PayloadTypeCore(){};
	~PayloadTypeCore();

	void setSelf(QSharedPointer<PayloadTypeCore> me);
	Family getFamily();
	bool isDownloadable();
	QString getMimeType();

protected:
	Family mFamily;
	bool mDownloadable = false;
	DECLARE_CORE_GETSET_MEMBER(bool, enabled, Enabled)
	DECLARE_CORE_MEMBER(QString, mimeType, MimeType)
	DECLARE_CORE_MEMBER(QString, encoderDescription, EncoderDescription)

private:
	std::shared_ptr<PayloadTypeModel> mPayloadTypeModel;
	QSharedPointer<SafeConnection<PayloadTypeCore, PayloadTypeModel>> mPayloadTypeModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
Q_DECLARE_METATYPE(PayloadTypeCore *)
#endif
