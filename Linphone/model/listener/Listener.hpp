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

#ifndef LISTENER_H_
#define LISTENER_H_

#include <QDebug>
#include <QThread>

class ListenerPrivate : public QObject {
	Q_OBJECT
public:
	ListenerPrivate() {
		connect(this, &ListenerPrivate::removeListener, this, &ListenerPrivate::onRemoveListener, Qt::QueuedConnection);
	}
	virtual void onRemoveListener() {
	}

signals:
	void removeListener();
};

template <class LinphoneClass, class ListenerClass>
class Listener : public ListenerPrivate {
public:
	Listener(std::shared_ptr<LinphoneClass> monitor, QObject *parent = nullptr) {
		setMonitor(monitor);
	}
	~Listener() {
		setSelf(nullptr);
		setMonitor(nullptr);
	}
	virtual void onRemoveListener() {
		setSelf(nullptr);
	}
	void setMonitor(std::shared_ptr<LinphoneClass> monitor) {
		if (mMonitor && mSelf) mMonitor->removeListener(mSelf);
		mMonitor = monitor;
		if (mMonitor && mSelf) mMonitor->addListener(mSelf);
	}
	void setSelf(const std::shared_ptr<ListenerClass> &self) {
		if (mMonitor && mSelf) mMonitor->removeListener(mSelf);
		mSelf = self;
		if (mMonitor && mSelf) mMonitor->addListener(self);
	}

	std::shared_ptr<LinphoneClass> getMonitor() const {
		return mMonitor;
	}

protected:
	std::shared_ptr<LinphoneClass> mMonitor;
	std::shared_ptr<ListenerClass> mSelf = nullptr;
};

#endif
