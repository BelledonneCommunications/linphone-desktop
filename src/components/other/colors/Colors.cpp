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

#include <linphone++/linphone.hh>
#include <QMetaProperty>

#if LINPHONE_FRIDAY
  #include <QDate>
#endif // if LINPHONE_FRIDAY

#include "utils/Utils.hpp"

#include "Colors.hpp"

// =============================================================================

using namespace std;

namespace {
  constexpr char ColorsSection[] = "ui_colors";
}

#if LINPHONE_FRIDAY
  static inline bool isLinphoneFriday () {
    return QDate::currentDate().dayOfWeek() == 5;
  }
#endif // if LINPHONE_FRIDAY

Colors::Colors (QObject *parent) : QObject(parent) {
  #if LINPHONE_FRIDAY
    if (isLinphoneFriday()) {
      setProperty("i", QColor("#F48D8D"));
      setProperty("b", QColor("#F58585"));
      setProperty("m", QColor("#FFC5C5"));
    }
  #endif // if LINPHONE_FRIDAY
}

void Colors::useConfig (const shared_ptr<linphone::Config> &config) {
  #if LINPHONE_FRIDAY
    if (!isLinphoneFriday())
      overrideColors(config);
  #else
    overrideColors(config);
  #endif // if LINPHONE_FRIDAY
}

// -----------------------------------------------------------------------------

void Colors::overrideColors (const shared_ptr<linphone::Config> &config) {
  if (!config)
    return;

  const QMetaObject *info = metaObject();

  for (int i = info->propertyOffset(); i < info->propertyCount(); ++i) {
    const QMetaProperty metaProperty = info->property(i);
    const string colorName = metaProperty.name();
    const string colorValue = config->getString(ColorsSection, colorName, "");

    if (!colorValue.empty())
      setProperty(colorName.c_str(), QColor(Utils::coreStringToAppString(colorValue)));
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
