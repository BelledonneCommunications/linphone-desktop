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

function getEntryIcon (item) {
  var iconRole = comboBox.iconRole
  if (iconRole == null || iconRole.length === 0) {
    return ''
  }

  return Utils.isFunction(iconRole)
    ? iconRole(item.flattenedModel)
    : item.flattenedModel[iconRole]
}
