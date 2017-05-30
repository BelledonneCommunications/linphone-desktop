/*
 * CallsListModel.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
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
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CALLS_LIST_MODEL_H_
#define CALLS_LIST_MODEL_H_

#include <QAbstractListModel>

#include "../call/CallModel.hpp"

// =============================================================================

class CoreHandlers;

class CallsListModel : public QAbstractListModel {
  Q_OBJECT;

public:
  CallsListModel (QObject *parent = Q_NULLPTR);
  ~CallsListModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  void askForTransfer (CallModel *callModel);

  Q_INVOKABLE void launchAudioCall (const QString &sipUri) const;
  Q_INVOKABLE void launchVideoCall (const QString &sipUri) const;

  Q_INVOKABLE int getRunningCallsNumber () const;

  Q_INVOKABLE void terminateAllCalls () const;

signals:
  void callRunning (int index, CallModel *callModel);
  void callTransferAsked (CallModel *callModel);

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::CallState state);

  void addCall (const std::shared_ptr<linphone::Call> &call);
  void removeCall (const std::shared_ptr<linphone::Call> &call);
  void removeCallCb (CallModel *callModel);

  QList<CallModel *> mList;

  std::shared_ptr<CoreHandlers> mCoreHandlers;
};

#endif // CALLS_LIST_MODEL_H_
