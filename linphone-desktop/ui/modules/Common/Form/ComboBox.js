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

function getEntryIcon (item) {
  var iconRole = comboBox.iconRole
  if (iconRole == null || iconRole.length === 0) {
    return ''
  }

  return Utils.isFunction(iconRole)
    ? iconRole(item.flattenedModel)
    : item.flattenedModel[iconRole]
}
