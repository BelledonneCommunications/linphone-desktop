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
	}                                                                                                                  \
	static inline QString sLog() {                                                                                     \
		return QStringLiteral("[%1]: %2").arg(#CLASS_NAME).arg("%1");                                                  \
	}

#define DECLARE_GUI_OBJECT                                                                                             \
Q_SIGNALS:                                                                                                             \
	void qmlNameChanged();                                                                                             \
                                                                                                                       \
public:                                                                                                                \
	Q_PROPERTY(QString qmlName READ getQmlName WRITE setQmlName NOTIFY qmlNameChanged)                                 \
	QString getQmlName() const;                                                                                        \
	void setQmlName(const QString &name);                                                                              \
	QString mQmlName;                                                                                                  \
	virtual inline QString log() const override {                                                                      \
		return AbstractObject::log().arg(QStringLiteral("%1 %2").arg(getQmlName()).arg("%1"));                         \
	}

#define DEFINE_GUI_OBJECT(CLASS_NAME)                                                                                  \
	QString CLASS_NAME::getQmlName() const {                                                                           \
		return mQmlName;                                                                                               \
	}                                                                                                                  \
	void CLASS_NAME::setQmlName(const QString &name) {                                                                 \
		if (mQmlName != name) {                                                                                        \
			mQmlName = name;                                                                                           \
			emit qmlNameChanged();                                                                                     \
		}                                                                                                              \
	}

#define DECLARE_CORE_GETSET_MEMBER(type, x, X)                                                                         \
	Q_PROPERTY(type x MEMBER m##X WRITE set##X NOTIFY x##Changed)                                                      \
	Q_SIGNAL void set##X(type data);                                                                                   \
	Q_SIGNAL void x##Changed();                                                                                        \
	type m##X;

#define DECLARE_CORE_MEMBER(type, x, X)                                                                                \
	Q_PROPERTY(type x MEMBER m##X NOTIFY x##Changed)                                                                   \
	Q_SIGNAL void x##Changed();                                                                                        \
	type m##X;

#define DECLARE_CORE_GETSET(type, x, X)                                                                                \
	Q_PROPERTY(type x READ get##X WRITE set##X NOTIFY x##Changed)                                                      \
	Q_SIGNAL void set##X(type data);                                                                                   \
	type get##X() const;                                                                                               \
	Q_SIGNAL void x##Changed();                                                                                        \
	type m##X;

#define DECLARE_GUI_GETSET(type, x, X)                                                                                 \
	Q_PROPERTY(type x READ get##X WRITE set##X NOTIFY x##Changed)                                                      \
	void set##X(type data);                                                                                            \
	type get##X() const;                                                                                               \
	Q_SIGNAL void x##Changed();                                                                                        \
	type m##X;

#define DECLARE_CORE_GET(type, x, X)                                                                                   \
	Q_PROPERTY(type x MEMBER m##X NOTIFY x##Changed)                                                                   \
	Q_SIGNAL void x##Changed();                                                                                        \
	type m##X;

#define DECLARE_GETSET(type, x, X)                                                                                     \
	type get##X() const;                                                                                               \
	void set##X(type data);                                                                                            \
	Q_SIGNAL void x##Changed(type x);

#define INIT_CORE_MEMBER(X, model) m##X = model->get##X();

#define DEFINE_CORE_GETSET_CONNECT(safe, CoreClass, ModelClass, model, type, x, X)                                     \
	safe->makeConnectToCore(&CoreClass::set##X, [this, objectToCall = model.get()](type data) {                        \
		safe->invokeToModel([this, data, objectToCall]() { objectToCall->set##X(data); });                             \
	});                                                                                                                \
	safe->makeConnectToModel(&ModelClass::x##Changed, [this](type data) {                                              \
		safe->invokeToCore([this, data]() {                                                                            \
			if (m##X != data) {                                                                                        \
				m##X = data;                                                                                           \
				emit x##Changed();                                                                                     \
			}                                                                                                          \
		});                                                                                                            \
	});

#define DEFINE_CORE_GET_CONNECT(safe, CoreClass, ModelClass, model, type, x, X)                                        \
	safe->makeConnectToModel(&ModelClass::x##Changed, [this](type data) {                                              \
		safe->invokeToCore([this, data]() {                                                                            \
			m##X = data;                                                                                               \
			emit x##Changed();                                                                                         \
		});                                                                                                            \
	});

#define DEFINE_GETSET_CONFIG(Class, type, Type, x, X, key, def)                                                        \
	type Class::get##X() const {                                                                                       \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return !!mConfig->get##Type(UiSection, key, def);                                                              \
	}                                                                                                                  \
	void Class::set##X(type data) {                                                                                    \
		if (get##X() != data) {                                                                                        \
			mConfig->set##Type(UiSection, key, data);                                                                  \
			emit x##Changed(data);                                                                                     \
		}                                                                                                              \
	}

#define DEFINE_GETSET_CONFIG_STRING(Class, x, X, key, def)                                                             \
	QString Class::get##X() const {                                                                                    \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return Utils::coreStringToAppString(mConfig->getString(UiSection, key, def));                                  \
	}                                                                                                                  \
	void Class::set##X(QString data) {                                                                                 \
		if (get##X() != data) {                                                                                        \
			mConfig->setString(UiSection, key, Utils::appStringToCoreString(data));                                    \
			emit x##Changed(data);                                                                                     \
		}                                                                                                              \
	}

#define DEFINE_NOTIFY_CONFIG_READY(x, X) emit x##Changed(get##X());

#define DECLARE_GETSET_API(type, x, X)                                                                                 \
	type get##X() const;                                                                                               \
	void set##X(type data);                                                                                            \
	Q_SIGNAL void x##Changed(type x);

#define DEFINE_GET_SET_API(Class, type, x, X)                                                                          \
	type Class::get##X() const {                                                                                       \
		return m##X;                                                                                                   \
	}                                                                                                                  \
	void Class::set##X(type data) {                                                                                    \
		if (get##X() != data) {                                                                                        \
			m##X = data;                                                                                               \
			emit x##Changed();                                                                                         \
		}                                                                                                              \
	}

#define DEFINE_GETSET(Class, type, x, X, ownerNotNull)                                                                 \
	type Class::get##X() const {                                                                                       \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return ownerNotNull->get##X();                                                                                 \
	}                                                                                                                  \
	void Class::set##X(type data) {                                                                                    \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		if (get##X() != data) {                                                                                        \
			ownerNotNull->set##X(data);                                                                                \
			emit x##Changed(data);                                                                                     \
		}                                                                                                              \
	}

#define DEFINE_GET(Class, type, X, ownerNotNull)                                                                       \
	type Class::get##X() const {                                                                                       \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return ownerNotNull->get##X();                                                                                 \
	}

#define DEFINE_GET_STRING(Class, X, ownerNotNull)                                                                      \
	QString Class::get##X() const {                                                                                    \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return Utils::coreStringToAppString(ownerNotNull->get##X());                                                   \
	}

#define DEFINE_GETSET_MODEL_STRING(Class, x, X, ownerNotNull)                                                          \
	QString Class::get##X() const {                                                                                    \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return Utils::coreStringToAppString(ownerNotNull->get##X());                                                   \
	}                                                                                                                  \
	void Class::set##X(QString data) {                                                                                 \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		if (get##X() != data) {                                                                                        \
			ownerNotNull->set##X(Utils::appStringToCoreString(data));                                                  \
			emit x##Changed(data);                                                                                     \
		}                                                                                                              \
	}

#define DEFINE_GETSET_ENABLED(Class, x, X, ownerNotNull)                                                               \
	bool Class::get##X() const {                                                                                       \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return ownerNotNull->x##Enabled();                                                                             \
	}                                                                                                                  \
	void Class::set##X(bool data) {                                                                                    \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		if (get##X() != data) {                                                                                        \
			ownerNotNull->enable##X(data);                                                                             \
			emit x##Changed(data);                                                                                     \
		}                                                                                                              \
	}

#define DEFINE_GETSET_ENABLE(Class, x, X, ownerNotNull)                                                                \
	bool Class::get##X() const {                                                                                       \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		return ownerNotNull->enabled();                                                                                \
	}                                                                                                                  \
	void Class::set##X(bool data) {                                                                                    \
		mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));                                                                \
		if (get##X() != data) {                                                                                        \
			ownerNotNull->enable(data);                                                                                \
			emit x##Changed(data);                                                                                     \
		}                                                                                                              \
	}

class AbstractObject {
public:
	virtual QString getClassName() const = 0;
	// return "[ClassName]: %1"
	virtual inline QString log() const {
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
