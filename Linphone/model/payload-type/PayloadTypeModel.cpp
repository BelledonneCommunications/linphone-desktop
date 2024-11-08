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

#include "PayloadTypeModel.hpp"
#include "tool/Utils.hpp"

DEFINE_ABSTRACT_OBJECT(PayloadTypeModel)

PayloadTypeModel::PayloadTypeModel(const std::shared_ptr<linphone::PayloadType> &payloadType, QObject *parent) {
	mustBeInLinphoneThread(getClassName());
	mPayloadType = payloadType;
}

PayloadTypeModel::~PayloadTypeModel() {
	mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
}

DEFINE_GETSET_ENABLE(PayloadTypeModel, enabled, Enabled, mPayloadType)
DEFINE_GET(PayloadTypeModel, int, ClockRate, mPayloadType)
DEFINE_GET_STRING(PayloadTypeModel, MimeType, mPayloadType)
DEFINE_GET_STRING(PayloadTypeModel, RecvFmtp, mPayloadType)
DEFINE_GET_STRING(PayloadTypeModel, EncoderDescription, mPayloadType)
