/*
 * Colors.cpp
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
 *  Created on: June 18, 2017
 *      Author: Ronan Abhamon
 */

#include <linphone++/linphone.hh>
#include <QMetaProperty>

#include "../../../utils/Utils.hpp"

#include "Colors.hpp"

#define COLORS_SECTION "ui_colors"

using namespace std;

// =============================================================================

Colors::Colors (QObject *parent) : QObject(parent) {}

void Colors::useConfig (const std::shared_ptr<linphone::Config> &config) {
  overrideColors(config);
}

// -----------------------------------------------------------------------------

void Colors::overrideColors (const shared_ptr<linphone::Config> &config) {
  const QMetaObject *info = metaObject();

  for (int i = info->propertyOffset(); i < info->propertyCount(); ++i) {
    const QMetaProperty metaProperty = info->property(i);
    const string colorName = metaProperty.name();
    const string colorValue = config->getString(COLORS_SECTION, colorName, "");

    if (!colorValue.empty())
      setProperty(colorName.c_str(), QColor(::Utils::coreStringToAppString(colorValue)));
  }
}

QStringList Colors::getColorNames () const {
  static QStringList colorNames;
  if (!colorNames.isEmpty())
    return colorNames;

  const QMetaObject *info = metaObject();
  for (int i = info->propertyOffset(); i < info->propertyCount(); ++i) {
    const QMetaProperty metaProperty = info->property(i);
    if (metaProperty.isWritable())
      colorNames << QString::fromLatin1(metaProperty.name());
  }

  return colorNames;
}
