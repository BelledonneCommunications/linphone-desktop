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
// `ComboBox.qml` Logic.
// =============================================================================

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function getSelectedEntryIcon () {
  var iconRole = comboBox.iconRole
  if (iconRole == null || iconRole.length === 0) {
    return ''
  }

  var currentIndex = comboBox.currentIndex
  if (currentIndex < 0) {
    return ''
  }

  var model = comboBox.model

  if (Utils.isFunction(iconRole)) {
    return iconRole(
      Utils.isArray(model)
        ? model[currentIndex]
        : model.get(currentIndex)
    )
  }

  return (
    Utils.isArray(model)
      ? model[currentIndex][iconRole]
      : model.get(currentIndex)[iconRole]
  ) || ''
}

function getSelectedEntryText () {
  if (comboBox.currentIndex < 0) {
    return ''
  }

  var text = comboBox.displayText
  if (text.length > 0) {
    return text
  }

  // With a `QAbstractListModel`, `text` is empty. QML bug?
  var model = comboBox.model
  if (model.data) {
    var item = model.data(model.index(comboBox.currentIndex, 0))
    var textRole = comboBox.textRole
    return textRole.length > 0 ? item[textRole] : item
  }

  return ''
}

function getItemIcon (item) {
  var iconRole = comboBox.iconRole
  if (iconRole == null || iconRole.length === 0) {
    return ''
  }

  return Utils.isFunction(iconRole)
    ? iconRole(item.flattenedModel)
    : item.flattenedModel[iconRole]
}
