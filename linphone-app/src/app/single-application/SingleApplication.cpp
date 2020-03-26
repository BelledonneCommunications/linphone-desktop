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

#include <cstdlib>
#include <iostream>

#include <QtCore/QDir>
#include <QtCore/QProcess>
#include <QtCore/QByteArray>
#include <QtCore/QSemaphore>
#include <QtCore/QSharedMemory>
#include <QtCore/QStandardPaths>
#include <QtCore/QCryptographicHash>
#include <QtNetwork/QLocalServer>
#include <QtNetwork/QLocalSocket>
#include <QProcess>

#ifdef Q_OS_UNIX
  #include <signal.h>
#endif // ifdef Q_OS_UNIX


#include "utils/Utils.hpp"

#include "SingleApplication.hpp"
#include "SingleApplicationPrivate.hpp"

#ifdef Q_OS_WIN
  #include <lmcons.h>
  #include <windows.h>
#endif // ifdef Q_OS_WIN
// =============================================================================

using namespace std;

namespace {
  constexpr char NewInstance = 'N';
  constexpr char SecondaryInstance = 'S';
  constexpr char Reconnect = 'R';
  constexpr char InvalidConnection = '\0';
}

// -----------------------------------------------------------------------------

SingleApplicationPrivate::SingleApplicationPrivate (SingleApplication *p_ptr) : q_ptr(p_ptr) {
  server = nullptr;
  socket = nullptr;
}

SingleApplicationPrivate::~SingleApplicationPrivate () {
  if (socket != nullptr) {
    socket->close();
    delete socket;
  }
  memory->lock();
  InstancesInfo *inst = static_cast<InstancesInfo *>(memory->data());
  if (server != nullptr) {
    server->close();
    delete server;
    inst->primary = false;
  }
  memory->unlock();
  delete memory;
}

void SingleApplicationPrivate::genBlockServerName (int timeout) {
  QCryptographicHash appData(QCryptographicHash::Sha256);
  appData.addData("SingleApplication", 17);
  appData.addData(QApplication::applicationName().toUtf8());
  appData.addData(QApplication::organizationName().toUtf8());
  appData.addData(QApplication::organizationDomain().toUtf8());

  if (!(options & SingleApplication::Mode::ExcludeAppVersion)) {
    appData.addData(QApplication::applicationVersion().toUtf8());
  }

  if (!(options & SingleApplication::Mode::ExcludeAppPath)) {
    #ifdef Q_OS_WIN
      appData.addData(QApplication::applicationFilePath().toLower().toUtf8());
    #else
      appData.addData(QApplication::applicationFilePath().toUtf8());
    #endif // ifdef Q_OS_WIN
  }

  // User level block requires a user specific data in the hash
  if (options & SingleApplication::Mode::User) {
    #ifdef Q_OS_WIN
      Q_UNUSED(timeout)
      wchar_t username[UNLEN + 1];
      // Specifies size of the buffer on input
      DWORD usernameLength = UNLEN + 1;
      if (GetUserNameW(username, &usernameLength)) {
        appData.addData(QString::fromWCharArray(username).toUtf8());
      } else {
        appData.addData(QStandardPaths::standardLocations(QStandardPaths::HomeLocation).join("").toUtf8());
      }
    #endif // ifdef Q_OS_WIN
    #ifdef Q_OS_UNIX
      QProcess process;
      process.start("whoami");
      if (process.waitForFinished(timeout) &&
          process.exitCode() == QProcess::NormalExit) {
        appData.addData(process.readLine());
      } else {
        appData.addData(
          QDir(
            QStandardPaths::standardLocations(QStandardPaths::HomeLocation).first()
          ).absolutePath().toUtf8()
        );
      }
    #endif // ifdef Q_OS_UNIX
  }

  // Replace the backslash in RFC 2045 Base64 [a-zA-Z0-9+/=] to comply with
  // server naming requirements.
  blockServerName = appData.result().toBase64().replace("/", "_");
}

void SingleApplicationPrivate::startPrimary (bool resetMemory) {
  #ifdef Q_OS_UNIX
    signal(SIGINT, SingleApplicationPrivate::terminate);
  #endif // ifdef Q_OS_UNIX

  // Successful creation means that no main process exists
  // So we start a QLocalServer to listen for connections
  QLocalServer::removeServer(blockServerName);
  server = new QLocalServer();

  // Restrict access to the socket according to the
  // SingleApplication::Mode::User flag on User level or no restrictions
  if (options & SingleApplication::Mode::User) {
    server->setSocketOptions(QLocalServer::UserAccessOption);
  } else {
    server->setSocketOptions(QLocalServer::WorldAccessOption);
  }

  server->listen(blockServerName);
  QObject::connect(
    server,
    &QLocalServer::newConnection,
    this,
    &SingleApplicationPrivate::slotConnectionEstablished
  );

  // Reset the number of connections
  memory->lock();
  InstancesInfo *inst = static_cast<InstancesInfo *>(memory->data());

  if (resetMemory) {
    inst->primary = true;
    inst->secondary = 0;
	inst->primaryId = q_ptr->applicationPid();
  } else {
    inst->primary = true;
	inst->primaryId = q_ptr->applicationPid();
  }

  memory->unlock();

  instanceNumber = 0;
}

void SingleApplicationPrivate::startSecondary () {
  #ifdef Q_OS_UNIX
    signal(SIGINT, SingleApplicationPrivate::terminate);
  #endif // ifdef Q_OS_UNIX
}

void SingleApplicationPrivate::connectToPrimary (int msecs, char connectionType) {
  // Connect to the Local Server of the Primary Instance if not already
  // connected.
  if (socket == nullptr) {
    socket = new QLocalSocket();
  }

  // If already connected - we are done;
  if (socket->state() == QLocalSocket::ConnectedState)
    return;

  // If not connect
  if (socket->state() == QLocalSocket::UnconnectedState ||
      socket->state() == QLocalSocket::ClosingState) {
    socket->connectToServer(blockServerName);
  }

  // Wait for being connected
  if (socket->state() == QLocalSocket::ConnectingState) {
    socket->waitForConnected(msecs);
  }

  // Initialisation message according to the SingleApplication protocol
  if (socket->state() == QLocalSocket::ConnectedState) {
    // Notify the parent that a new instance had been started;
    QByteArray initMsg = blockServerName.toLatin1();

    initMsg.append(connectionType);
    initMsg.append(reinterpret_cast<const char *>(&instanceNumber), sizeof(quint32));
    initMsg.append(QByteArray::number(qChecksum(initMsg.constData(), uint(initMsg.length())), 256));

    socket->write(initMsg);
    socket->flush();
    socket->waitForBytesWritten(msecs);
  }
}

#ifdef Q_OS_UNIX
  void SingleApplicationPrivate::terminate (int signum) {
    Q_UNUSED(signum);
    SingleApplication::instance()->quit();
  }
#endif // ifdef Q_OS_UNIX

/**
 * @brief Executed when a connection has been made to the LocalServer
 */
void SingleApplicationPrivate::slotConnectionEstablished () {
  Q_Q(SingleApplication);

  QLocalSocket *nextConnSocket = server->nextPendingConnection();

  // Verify that the new connection follows the SingleApplication protocol
  char connectionType = InvalidConnection;
  quint32 instanceId;
  QByteArray initMsg, tmp;
  if (nextConnSocket->waitForReadyRead(100)) {
    tmp = nextConnSocket->read(blockServerName.length());
    // Verify that the socket data start with blockServerName
    if (tmp == blockServerName.toLatin1()) {
      initMsg = tmp;
      connectionType = nextConnSocket->read(1)[0];

      switch (connectionType) {
        case NewInstance:
        case SecondaryInstance:
        case Reconnect: {
          initMsg += connectionType;
          tmp = nextConnSocket->read(sizeof(quint32));
          const char *data = tmp.constData();
          instanceId = quint32(*data);
          initMsg += tmp;
          // Verify the checksum of the initMsg
          QByteArray checksum = QByteArray::number(
              qChecksum(initMsg.constData(), uint(initMsg.length())),
              256
            );
          tmp = nextConnSocket->read(checksum.length());
          if (checksum == tmp)
            break; // Otherwise set to invalid connection (next line)
          connectionType = InvalidConnection;
          break;
        }
        default:
          connectionType = InvalidConnection;
      }
    }
  }

  if (connectionType == InvalidConnection) {
    nextConnSocket->close();
    delete nextConnSocket;
    return;
  }

  QObject::connect(nextConnSocket, &QLocalSocket::aboutToClose, this, [nextConnSocket, instanceId, this]() {
    emit this->slotClientConnectionClosed(nextConnSocket, instanceId);
  });

  QObject::connect(nextConnSocket, &QLocalSocket::readyRead, this, [nextConnSocket, instanceId, this]() {
    emit this->slotDataAvailable(nextConnSocket, instanceId);
  });

  if (connectionType == NewInstance || (
        connectionType == SecondaryInstance &&
        options & SingleApplication::Mode::SecondaryNotification
      )
  ) {
    emit q->instanceStarted();
  }

  if (nextConnSocket->bytesAvailable() > 0) {
    emit this->slotDataAvailable(nextConnSocket, instanceId);
  }
}

void SingleApplicationPrivate::slotDataAvailable (QLocalSocket *dataSocket, quint32 instanceId) {
  Q_Q(SingleApplication);
  emit q->receivedMessage(instanceId, dataSocket->readAll());
}

void SingleApplicationPrivate::slotClientConnectionClosed (QLocalSocket *closedSocket, quint32 instanceId) {
  if (closedSocket->bytesAvailable() > 0)
    emit slotDataAvailable(closedSocket, instanceId);
  closedSocket->deleteLater();
}

/**
 * @brief Constructor. Checks and fires up LocalServer or closes the program
 * if another instance already exists
 * @param argc
 * @param argv
 * @param {bool} allowSecondaryInstances
 */
SingleApplication::SingleApplication (int &argc, char *argv[], bool allowSecondary, Options options, int timeout)
  : QApplication(argc, argv), d_ptr(new SingleApplicationPrivate(this)) {
  Q_D(SingleApplication);

  // Store the current mode of the program
  d->options = options;

  // Generating an application ID used for identifying the shared memory
  // block and QLocalServer
  d->genBlockServerName(timeout);

  // Guarantee thread safe behaviour with a shared memory block. Also by
  // explicitly attaching it and then deleting it we make sure that the
  // memory is deleted even if the process had crashed on Unix.
  #ifdef Q_OS_UNIX
    d->memory = new QSharedMemory(d->blockServerName);
    d->memory->attach();
    delete d->memory;
  #endif // ifdef Q_OS_UNIX
  d->memory = new QSharedMemory(d->blockServerName);

  // Create a shared memory block
  if (d->memory->create(sizeof(InstancesInfo))) {
    d->startPrimary(true);
    return;
  }

  // Attempt to attach to the memory segment
  if (d->memory->attach()) {
    d->memory->lock();
	
    InstancesInfo *inst = static_cast<InstancesInfo *>(d->memory->data());

    if (!inst->primary || !Utils::processExists(inst->primaryId)) { // Check if there is not a primary instance and if there is, is it still running?
      d->startPrimary(false);
      d->memory->unlock();
      return;
    }

    // Check if another instance can be started
    if (allowSecondary) {
      inst->secondary += 1;
      d->instanceNumber = inst->secondary;

      d->startSecondary();
      if (d->options & Mode::SecondaryNotification)
        d->connectToPrimary(timeout, SecondaryInstance);

      d->memory->unlock();

      return;
    }

    d->memory->unlock();
  }

  d->connectToPrimary(timeout, NewInstance);
  delete d;
  ::exit(EXIT_SUCCESS);
}

/**
 * @brief Destructor
 */
SingleApplication::~SingleApplication () {
  Q_D(SingleApplication);
  delete d;
}

bool SingleApplication::isPrimary () {
  Q_D(SingleApplication);
  return d->server != nullptr;
}

bool SingleApplication::isSecondary () {
  Q_D(SingleApplication);
  return d->server == nullptr;
}

quint32 SingleApplication::instanceId () {
  Q_D(SingleApplication);
  return d->instanceNumber;
}

bool SingleApplication::sendMessage (QByteArray message, int timeout) {
  Q_D(SingleApplication);

  // Nobody to connect to
  if (isPrimary()) return false;
  // Make sure the socket is connected

  d->connectToPrimary(timeout, Reconnect);
  d->socket->write(message);
  bool dataWritten = d->socket->flush();
  d->socket->waitForBytesWritten(timeout);
  return dataWritten;
}

void SingleApplication::quit () {
  QCoreApplication::quit();
}
