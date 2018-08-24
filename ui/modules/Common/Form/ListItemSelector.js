// =============================================================================
// `ListItemSelector.qml` Logic.
// =============================================================================

.import 'qrc:/ui/scripts/Utils/utils.js' as Utils

// =============================================================================

function getEntryIcon (item) {
  var iconRole = view.iconRole
  if (iconRole == null || iconRole.length === 0) {
    return ''
  }

  return Utils.isFunction(iconRole)
    ? iconRole(item.flattenedModel)
    : item.flattenedModel[iconRole]
}
