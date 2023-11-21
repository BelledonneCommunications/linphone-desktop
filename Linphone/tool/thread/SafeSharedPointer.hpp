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

#ifndef SAFE_SHARED_POINTER_H_
#define SAFE_SHARED_POINTER_H_

#include <QDebug>
#include <QSharedPointer>

// Store a Qt/Std shared pointer
template <typename A>
class SafeSharedPointer {
public:
	QSharedPointer<A> mQData;
	QWeakPointer<A> mQDataWeak;
	std::shared_ptr<A> mStdData;
	std::weak_ptr<A> mStdDataWeak;
	int mCountRef = 0;

	SafeSharedPointer(QSharedPointer<A> p) : mQDataWeak(p) {
	}
	SafeSharedPointer(std::shared_ptr<A> p) : mStdDataWeak(p) {
	}

	bool lock() {
		if (mCountRef == 0) {
			if (!mQDataWeak.isNull()) {
				mQData = mQDataWeak.lock();
				if (mQData) ++mCountRef;
				return !mQData.isNull();
			} else if (!mStdDataWeak.expired()) {
				mStdData = mStdDataWeak.lock();
				if (mStdData) ++mCountRef;
				return mStdData != nullptr;
			}
			return false;
		} else {
			++mCountRef;
			return true;
		}
	}
	void unlock() {
		if (mCountRef == 0) qWarning() << "[SafeConnection] too much unlocking";
		else if (--mCountRef == 0) {
			mQData = nullptr;
			mStdData = nullptr;
		}
	}
	void reset() {
		mQData = nullptr;
		mStdData = nullptr;
		mCountRef = 0;
	}
	A *get() {
		if (mQData) return mQData.get();
		if (mStdData) return mStdData.get();
		return nullptr;
	}
};

#endif
