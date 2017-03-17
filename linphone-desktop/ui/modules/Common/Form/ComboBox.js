// =============================================================================
// `ComboBox.qml` Logic.
// =============================================================================

function getSelectedEntryIcon () {
  var iconRole = comboBox.iconRole
  if (iconRole.length === 0) {
    return ''
  }

  var currentIndex = comboBox.currentIndex
  if (currentIndex < 0) {
    return ''
  }

  var model = comboBox.model
  return (
    Utils.isArray(model)
      ? model[currentIndex][iconRole]
      : model.get(currentIndex)[iconRole]
  ) || ''
}

function getEntryIcon (item) {
  var iconRole = comboBox.iconRole
  return (iconRole.length && item.flattenedModel[iconRole]) || ''
}
