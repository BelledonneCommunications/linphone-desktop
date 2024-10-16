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

#include "PhoneNumberList.hpp"
#include "PhoneNumber.hpp"
#include "core/App.hpp"
#include <QSharedPointer>
#include <QString>
#include <linphone++/linphone.hh>
// =============================================================================

DEFINE_ABSTRACT_OBJECT(PhoneNumberList)

QSharedPointer<PhoneNumberList> PhoneNumberList::create() {
	auto model = QSharedPointer<PhoneNumberList>(new PhoneNumberList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	return model;
}

PhoneNumberList::PhoneNumberList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(getClassName());
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	App::postModelAsync([=]() {
		// Model thread.
		auto dialPlans = linphone::Factory::get()->getDialPlans();
		QList<QSharedPointer<PhoneNumber>> *numbers = new QList<QSharedPointer<PhoneNumber>>();
		for (auto it : dialPlans) {
			auto numberModel = PhoneNumber::create(it);
			numbers->push_back(numberModel);
		}
		// Invoke for adding stuffs in caller thread
		QMetaObject::invokeMethod(this, [this, numbers]() {
			mustBeInMainThread(this->log().arg(Q_FUNC_INFO));
			resetData<PhoneNumber>(*numbers);
			delete numbers;
		});
	});
}

PhoneNumberList::~PhoneNumberList() {
	mustBeInMainThread("~" + getClassName());
}
