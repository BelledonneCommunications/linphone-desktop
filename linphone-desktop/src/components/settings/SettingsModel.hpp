/*
 * SettingsModel.hpp
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

#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class SettingsModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QList<int> audioPortRange READ getAudioPortRange WRITE setAudioPortRange NOTIFY audioPortRangeChanged);
  Q_PROPERTY(QList<int> videoPortRange READ getVideoPortRange WRITE setVideoPortRange NOTIFY videoPortRangeChanged);

  Q_PROPERTY(bool useSipInfoForDtmfs READ getUseSipInfoForDtmfs WRITE setUseSipInfoForDtmfs NOTIFY dtmfsProtocolChanged);
  Q_PROPERTY(bool useRfc2833ForDtmfs READ getUseRfc2833ForDtmfs WRITE setUseRfc2833ForDtmfs NOTIFY dtmfsProtocolChanged);

  Q_PROPERTY(bool ipv6Enabled READ getIpv6Enabled WRITE setIpv6Enabled NOTIFY ipv6EnabledChanged);

  Q_PROPERTY(bool autoAnswerStatus READ getAutoAnswerStatus WRITE setAutoAnswerStatus NOTIFY autoAnswerStatusChanged);
  Q_PROPERTY(QString fileTransferUrl READ getFileTransferUrl WRITE setFileTransferUrl NOTIFY fileTransferUrlChanged);

  Q_PROPERTY(QString savedScreenshotsFolder READ getSavedScreenshotsFolder WRITE setSavedScreenshotsFolder NOTIFY savedScreenshotsFolderChanged);
  Q_PROPERTY(QString savedVideosFolder READ getSavedVideosFolder WRITE setSavedVideosFolder NOTIFY savedVideosFolderChanged);

public:
  SettingsModel (QObject *parent = Q_NULLPTR);

  // Network. ------------------------------------------------------------------

  QList<int> getAudioPortRange () const;
  void setAudioPortRange (const QList<int> &range);

  QList<int> getVideoPortRange () const;
  void setVideoPortRange (const QList<int> &range);

  bool getUseSipInfoForDtmfs () const;
  void setUseSipInfoForDtmfs (bool status);

  bool getUseRfc2833ForDtmfs () const;
  void setUseRfc2833ForDtmfs (bool status);

  bool getIpv6Enabled () const;
  void setIpv6Enabled (bool status);

  // Misc. ---------------------------------------------------------------------

  bool getAutoAnswerStatus () const;
  void setAutoAnswerStatus (bool status);

  QString getFileTransferUrl () const;
  void setFileTransferUrl (const QString &url);

  QString getSavedScreenshotsFolder () const;
  void setSavedScreenshotsFolder (const QString &folder);

  QString getSavedVideosFolder () const;
  void setSavedVideosFolder (const QString &folder);

  // ---------------------------------------------------------------------------

  static const std::string UI_SECTION;

signals:
  void audioPortRangeChanged (int a, int b);
  void videoPortRangeChanged (int a, int b);

  void dtmfsProtocolChanged ();

  void ipv6EnabledChanged (bool status);

  void autoAnswerStatusChanged (bool status);
  void fileTransferUrlChanged (const QString &url);

  void savedScreenshotsFolderChanged (const QString &folder);
  void savedVideosFolderChanged (const QString &folder);

private:
  std::shared_ptr<linphone::Config> m_config;
};

#endif // SETTINGS_MODEL_H_
