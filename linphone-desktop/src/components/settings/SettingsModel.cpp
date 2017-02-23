/*
 * SettingsModel.cpp
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

#include "../../app/Paths.hpp"
#include "../../utils.hpp"
#include "../core/CoreManager.hpp"

#include <QDir>

#include "SettingsModel.hpp"

using namespace std;

// =============================================================================

const string SettingsModel::UI_SECTION("ui");

SettingsModel::SettingsModel (QObject *parent) : QObject(parent) {
  m_config = CoreManager::getInstance()->getCore()->getConfig();
}

// -----------------------------------------------------------------------------

bool SettingsModel::getAutoAnswerStatus () const {
  return !!m_config->getInt(UI_SECTION, "auto_answer", 0);
}

void SettingsModel::setAutoAnswerStatus (bool status) {
  m_config->setInt(UI_SECTION, "auto_answer", status);
  emit autoAnswerStatusChanged(status);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getFileTransferUrl () const {
  return ::Utils::linphoneStringToQString(
    CoreManager::getInstance()->getCore()->getFileTransferServer()
  );
}

void SettingsModel::setFileTransferUrl (const QString &url) {
  CoreManager::getInstance()->getCore()->setFileTransferServer(
    ::Utils::qStringToLinphoneString(url)
  );
}

// -----------------------------------------------------------------------------

QString SettingsModel::getSavedScreenshotsFolder () const {
  return QDir::cleanPath(
    ::Utils::linphoneStringToQString(
      m_config->getString(UI_SECTION, "saved_screenshots_folder", Paths::getCapturesDirPath())
    )
  ) + QDir::separator();
}

void SettingsModel::setSavedScreenshotsFolder (const QString &folder) {
  QString _folder = QDir::cleanPath(folder) + QDir::separator();

  m_config->setString(UI_SECTION, "saved_screenshots_folder", ::Utils::qStringToLinphoneString(_folder));
  emit savedScreenshotsFolderChanged(_folder);
}

// -----------------------------------------------------------------------------

QString SettingsModel::getSavedVideosFolder () const {
  return QDir::cleanPath(
    ::Utils::linphoneStringToQString(
      m_config->getString(UI_SECTION, "saved_videos_folder", Paths::getCapturesDirPath())
    )
  ) + QDir::separator();
}

void SettingsModel::setSavedVideosFolder (const QString &folder) {
  QString _folder = QDir::cleanPath(folder) + QDir::separator();

  m_config->setString(UI_SECTION, "saved_videos_folder", ::Utils::qStringToLinphoneString(_folder));
  emit savedVideosFolderChanged(_folder);
}
