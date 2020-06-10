import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common.Styles 1.0

// =============================================================================
// Responsive flat menu with visual indicators.
// =============================================================================

Rectangle {
  id: menu

  // ---------------------------------------------------------------------------

  property var defaultSelectedEntry: null

  property int entryHeight
  property int entryWidth

  property var _selected: defaultSelectedEntry

  default property alias _content: content.data

  // ---------------------------------------------------------------------------

  function resetSelectedEntry () {
    _selected = null
  }

  // ---------------------------------------------------------------------------

  color: ApplicationMenuStyle.backgroundColor
  implicitHeight: content.height
  width: entryWidth

  Column {
    id: content

    width: parent.width
    spacing: ApplicationMenuStyle.spacing
  }
}
