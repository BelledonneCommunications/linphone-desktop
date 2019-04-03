/*
 * EventCountNotifierMacOs.hpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: June 30, 2017
 *      Author: Ghislain MARY
 */

#ifndef EVENT_COUNT_NOTIFIER_MAC_OS_H_
#define EVENT_COUNT_NOTIFIER_MAC_OS_H_

#include "AbstractEventCountNotifier.hpp"

// =============================================================================

extern "C" void notifyEventCountMacOs (int n);

class EventCountNotifier : public AbstractEventCountNotifier {
public:
  EventCountNotifier (QObject *parent = Q_NULLPTR) : AbstractEventCountNotifier(parent) {}

  void notifyEventCount (int n) override {
    notifyEventCountMacOs(n);
  }
};

#endif // EVENT_COUNT_NOTIFIER_MAC_OS_H_
