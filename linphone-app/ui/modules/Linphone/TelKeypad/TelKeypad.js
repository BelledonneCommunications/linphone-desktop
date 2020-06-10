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
// =============================================================================
// `TelKeypad.qml` Logic.
// =============================================================================

.import Linphone.Styles 1.0 as LinphoneStyles

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function mapKeyToButtonIndex (key) {
  // Digits.
  if (key === 48) {
    return 13
  }

  if (key >= 49 && key <= 57) {
    return (key - 49) + parseInt((key - 49) / 3)
  }

  // A, B, C and D.
  if (key >= 65 && key <= 68) {
    return (key - 65) * 4 + 3
  }

  // *
  if (key === 42) {
    return 12
  }

  // #
  if (key === 35) {
    return 14
  }
}

function sendDtmf (index) {
  var children = grid.children[index]

  children.color = LinphoneStyles.TelKeypadStyle.button.color.pressed
  children.clicked()

  var timeout = children._timeout
  if (timeout) {
    Utils.clearTimeout(timeout)
  }

  children._timeout = Utils.setTimeout(dragBox, 100, (function (index) {
    grid.children[index].color = LinphoneStyles.TelKeypadStyle.button.color.normal
  }).bind(dragBox, index))
}
