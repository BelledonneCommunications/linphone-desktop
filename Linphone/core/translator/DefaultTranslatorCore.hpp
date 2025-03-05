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

#ifndef DEFAULT_TRANSLATOR_CORE_H_
#define DEFAULT_TRANSLATOR_CORE_H_

#include <QSet>
#include <QTranslator>

// =============================================================================

class DefaultTranslatorCore : public QTranslator {
public:
  DefaultTranslatorCore (QObject *parent = Q_NULLPTR);

  QString translate (
    const char *context,
    const char *sourceText,
    const char *disambiguation = Q_NULLPTR,
    int n = -1
  ) const override;

private:
  QSet<QString> mContexts;
};

// Workaround for bad Application Menu translation on Mac:
// Overwrite Qt source by our translations :
//static const char *application_menu_strings[] =
//{
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","About %1"),
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","Preferences…"),
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","Services"),
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","Hide %1"),
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","Hide Others"),
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","Show All"),
//    QT_TRANSLATE_NOOP("MAC_APPLICATION_MENU","Quit %1")
//};

//class MAC_APPLICATION_MENU : public QObject{
//	QString forcedTranslation(){
//		return tr("About %1") + tr("Preferences…") + tr("Services") + tr("Hide %1") + tr("Hide Others") + tr("Show All") + tr("Quit %1");
//	}
//};

#endif // DEFAULT_TRANSLATOR_CORE_H_
