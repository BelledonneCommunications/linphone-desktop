/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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
// The MIT License (MIT)
//
// Copyright (c) Itay Grudev 2015 - 2016
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//
// W A R N I N G !!!
// -----------------
//
// This file is not part of the SingleApplication API. It is used purely as an
// implementation detail. This header file may change from version to
// version without notice, or may even be removed.
//

#ifndef SINGLE_APPLICATION_PRIVATE_H_
#define SINGLE_APPLICATION_PRIVATE_H_

#include <QtCore/QMutex>
#include <QtCore/QSharedMemory>
#include <QtNetwork/QLocalServer>
#include <QtNetwork/QLocalSocket>

#include "SingleApplication.hpp"

// =============================================================================

struct InstancesInfo {
  bool primary;
  quint32 secondary;
  qint64 primaryId;
};

class SingleApplicationPrivate : public QObject {
  Q_OBJECT

public:
  Q_DECLARE_PUBLIC(SingleApplication) SingleApplicationPrivate (SingleApplication *q_ptr);
  ~SingleApplicationPrivate ();

  void genBlockServerName (int msecs);
  void startPrimary (bool resetMemory);
  void startSecondary ();
  void connectToPrimary (int msecs, char connectionType);

  #ifdef Q_OS_UNIX
    static void terminate (int signum);
  #endif // ifdef Q_OS_UNIX

  QSharedMemory *memory;
  SingleApplication *q_ptr;
  QLocalSocket *socket;
  QLocalServer *server;
  quint32 instanceNumber;
  QString blockServerName;
  SingleApplication::Options options;

public Q_SLOTS:
  void slotConnectionEstablished ();
  void slotDataAvailable (QLocalSocket *, quint32);
  void slotClientConnectionClosed (QLocalSocket *, quint32);
};

#endif // SINGLE_APPLICATION_PRIVATE_H_
