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

#ifndef THREAD_H_
#define THREAD_H_

#include <QThread>

class Thread : public QThread {
public:
	Thread(QObject *parent = nullptr);
	virtual ~Thread();
	static bool isInLinphoneThread();
	static bool mustBeInLinphoneThread(const QString &context);
	static bool mustBeInMainThread(const QString &context);

	QObject *getThreadId();

	virtual void run();
	QObject *mThreadId = nullptr;
};
#endif
