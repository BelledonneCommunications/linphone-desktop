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

#include "Utils.hpp"

#include "core/App.hpp"
#include "core/call/CallGui.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"

// =============================================================================

char *Utils::rstrstr(const char *a, const char *b) {
	size_t a_len = strlen(a);
	size_t b_len = strlen(b);

	if (b_len > a_len) return nullptr;

	for (const char *s = a + a_len - b_len; s >= a; --s) {
		if (!strncmp(s, b, b_len)) return const_cast<char *>(s);
	}

	return nullptr;
}

VariantObject *Utils::getDisplayName(const QString &address) {
	VariantObject *data = new VariantObject(address); // Scope : GUI
	data->makeRequest([address]() {
		QString displayName = ToolModel::getDisplayName(address);
		return displayName;
	});
	data->requestValue();
	return data;
}

VariantObject *Utils::createCall(const QString &sipAddress,
                                 const QString &prepareTransfertAddress,
                                 const QHash<QString, QString> &headers) {
	VariantObject *data = new VariantObject(QVariant()); // Scope : GUI

	data->makeRequest([sipAddress, prepareTransfertAddress, headers]() {
		auto call = ToolModel::createCall(sipAddress, prepareTransfertAddress, headers);
		if (call) {
			return QVariant::fromValue(new CallGui(call));
		} else return QVariant();
	});
	data->requestValue();

	return data;
}

VariantObject *Utils::haveAccount() {
	VariantObject *result = new VariantObject();

	// Using connect ensure to have sender() and receiver() alive.
	result->makeRequest([]() {
		// Model
		return CoreModel::getInstance()->getCore()->getAccountList().size() > 0;
	});
	result->makeUpdate(CoreModel::getInstance().get(), &CoreModel::accountAdded);
	result->requestValue();
	return result;
}
