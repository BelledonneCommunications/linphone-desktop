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

#ifndef ABSTRACT_OBJECT_H_
#define ABSTRACT_OBJECT_H_
#include <QString>

#include "thread/Thread.hpp"

#define DECLARE_ABSTRACT_OBJECT                                                                                        \
	virtual QString getClassName() const override;                                                                     \
	static const char *gClassName;

#define DEFINE_ABSTRACT_OBJECT(CLASS_NAME)                                                                             \
	const char *CLASS_NAME::gClassName = #CLASS_NAME;                                                                  \
	QString CLASS_NAME::getClassName() const {                                                                         \
		return gClassName;                                                                                             \
	}

class AbstractObject {
public:
	virtual QString getClassName() const = 0;
	// return "[ClassName]: %1"
	inline QString log() const {
		return QStringLiteral("[%1]: %2").arg(getClassName()).arg("%1");
	}
	inline static bool isInLinphoneThread() {
		return Thread::isInLinphoneThread();
	}
	inline static bool mustBeInLinphoneThread(const QString &context) { // For convenience : Alias to Thread
		return Thread::mustBeInLinphoneThread(context);
	}
	inline static bool mustBeInMainThread(const QString &context) { // For convenience : Alias to Thread
		return Thread::mustBeInMainThread(context);
	}
};
#endif
