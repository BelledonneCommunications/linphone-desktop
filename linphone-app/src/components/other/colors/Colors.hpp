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

#ifndef COLORS_H_
#define COLORS_H_

#include <memory>

#include <QColor>
#include <QObject>

// =============================================================================

#define ADD_COLOR(COLOR, VALUE) \
  Q_PROPERTY(QColor COLOR MEMBER m ## COLOR WRITE set ## COLOR NOTIFY colorT ## COLOR ## Changed); \
  void set ## COLOR(const QColor &color) { \
    m ## COLOR = color; \
    emit colorT ## COLOR ## Changed(m ## COLOR); \
  } \
  QColor m ## COLOR = VALUE;

// Alpha is in percent.
#define ADD_COLOR_WITH_ALPHA(COLOR, ALPHA) \
  Q_PROPERTY(QColor COLOR ## ALPHA READ get ## COLOR ## ALPHA NOTIFY colorT ## COLOR ## Changed); \
  QColor get ## COLOR ## ALPHA() { \
    QColor color = m ## COLOR; \
    color.setAlpha(ALPHA * 255 / 100); \
    return color; \
  }

// -----------------------------------------------------------------------------

namespace linphone {
  class Config;
}

class Colors : public QObject {
  Q_OBJECT

  Q_PROPERTY(QStringList colorNames READ getColorNames CONSTANT)

  ADD_COLOR(a, "transparent")

  // Primary color for hovered items.
  ADD_COLOR(b, "#D64D00")

  ADD_COLOR(c, "#CBCBCB")
  ADD_COLOR(d, "#5A585B")
  ADD_COLOR(e, "#F3F3F3")
  ADD_COLOR(f, "#E8E8E8")
  ADD_COLOR(g, "#6B7A86")
  ADD_COLOR(h, "#687680")

  // Primary color.
  ADD_COLOR(i, "#FE5E00")

  ADD_COLOR(j, "#4B5964")

  // Popups, home, call, assistant and settings background.
  ADD_COLOR(k, "#FFFFFF")

  ADD_COLOR(l, "#000000")

  // Primary color for clicked items.
  ADD_COLOR(m, "#FF8600")

  ADD_COLOR(n, "#A1A1A1")
  ADD_COLOR(o, "#D0D8DE")

  // Progress bar.
  ADD_COLOR(p, "#17A81A")

  // Fields, backgrounds and text color on some items.
  ADD_COLOR(q, "#FFFFFF")

  // Field error.
  ADD_COLOR(error, "#FF0000")

  ADD_COLOR_WITH_ALPHA(g, 10)
  ADD_COLOR_WITH_ALPHA(g, 20)
  ADD_COLOR_WITH_ALPHA(g, 90)
  ADD_COLOR_WITH_ALPHA(i, 30)
  ADD_COLOR_WITH_ALPHA(l, 50)
  ADD_COLOR_WITH_ALPHA(l, 80)
  ADD_COLOR_WITH_ALPHA(q, 50)

public:
  Colors (QObject *parent = Q_NULLPTR);

  void useConfig (const std::shared_ptr<linphone::Config> &config);

signals:
  void colorTaChanged (const QColor &color);
  void colorTbChanged (const QColor &color);
  void colorTcChanged (const QColor &color);
  void colorTdChanged (const QColor &color);
  void colorTeChanged (const QColor &color);
  void colorTfChanged (const QColor &color);
  void colorTgChanged (const QColor &color);
  void colorThChanged (const QColor &color);
  void colorTiChanged (const QColor &color);
  void colorTjChanged (const QColor &color);
  void colorTkChanged (const QColor &color);
  void colorTlChanged (const QColor &color);
  void colorTmChanged (const QColor &color);
  void colorTnChanged (const QColor &color);
  void colorToChanged (const QColor &color);
  void colorTpChanged (const QColor &color);
  void colorTqChanged (const QColor &color);

  void colorTerrorChanged (const QColor &color);

private:
  void overrideColors (const std::shared_ptr<linphone::Config> &config);

  QStringList getColorNames () const;
};

// -----------------------------------------------------------------------------

#undef ADD_COLOR_WITH_ALPHA
#undef ADD_COLOR

#endif // COLORS_H_
