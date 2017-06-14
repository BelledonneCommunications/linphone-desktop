/*
 * ConferenceModel.hpp
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
 *  Created on: May 23, 2017
 *      Author: Ronan Abhamon
 */

#ifndef CONFERENCE_MODEL_H_
#define CONFERENCE_MODEL_H_

#include <QSortFilterProxyModel>

// =============================================================================

class CallModel;

class ConferenceModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(int count READ getCount NOTIFY countChanged);

  Q_PROPERTY(bool microMuted READ getMicroMuted WRITE setMicroMuted NOTIFY microMutedChanged);
  Q_PROPERTY(float microVu READ getMicroVu CONSTANT);

  Q_PROPERTY(bool recording READ getRecording NOTIFY recordingChanged);
  Q_PROPERTY(bool isInConf READ isInConference NOTIFY conferenceChanged);

public:
  ConferenceModel (QObject *parent = Q_NULLPTR);
  ~ConferenceModel () = default;

protected:
  bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;

  Q_INVOKABLE void terminate ();

  Q_INVOKABLE void startRecording ();
  Q_INVOKABLE void stopRecording ();

  Q_INVOKABLE void join ();
  Q_INVOKABLE void leave ();

signals:
  void countChanged (int count);

  void microMutedChanged (bool status);
  void recordingChanged (bool status);
  void conferenceChanged ();

private:
  int getCount () const {
    return rowCount();
  }

  bool getMicroMuted () const;
  void setMicroMuted (bool status);
  float getMicroVu () const;

  bool isInConference () const;

  bool getRecording () const;

  bool mRecording = false;
};

#endif // CONFERENCE_MODEL_H_
