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

#include "PayloadTypeCore.hpp"
#include "core/App.hpp"

DEFINE_ABSTRACT_OBJECT(PayloadTypeCore)

QSharedPointer<PayloadTypeCore> PayloadTypeCore::create(Family family,
                                                        const std::shared_ptr<linphone::PayloadType> &payloadType) {
	auto sharedPointer =
	    QSharedPointer<PayloadTypeCore>(new PayloadTypeCore(family, payloadType), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

PayloadTypeCore::PayloadTypeCore(Family family, const std::shared_ptr<linphone::PayloadType> &payloadType)
    : QObject(nullptr) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
	mPayloadTypeModel = Utils::makeQObject_ptr<PayloadTypeModel>(payloadType);
	mFamily = family;
	INIT_CORE_MEMBER(Enabled, mPayloadTypeModel)
	INIT_CORE_MEMBER(ClockRate, mPayloadTypeModel)
	INIT_CORE_MEMBER(MimeType, mPayloadTypeModel)
	INIT_CORE_MEMBER(RecvFmtp, mPayloadTypeModel)
	INIT_CORE_MEMBER(EncoderDescription, mPayloadTypeModel)
}

PayloadTypeCore::~PayloadTypeCore() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
}

void PayloadTypeCore::setSelf(QSharedPointer<PayloadTypeCore> me) {
	mPayloadTypeModelConnection = SafeConnection<PayloadTypeCore, PayloadTypeModel>::create(me, mPayloadTypeModel);
	DEFINE_CORE_GETSET_CONNECT(mPayloadTypeModelConnection, PayloadTypeCore, PayloadTypeModel, mPayloadTypeModel, bool,
	                           enabled, Enabled)
}

PayloadTypeCore::Family PayloadTypeCore::getFamily() {
	return mFamily;
}

QString PayloadTypeCore::getMimeType() {
	return mMimeType;
}

bool PayloadTypeCore::isDownloadable() {
	return mDownloadable;
}
