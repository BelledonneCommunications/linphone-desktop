import QtQuick 2.7

// =============================================================================

Loader {
  id: loader

  // ---------------------------------------------------------------------------

  property string label
  readonly property int orientation: parent.orientation
  readonly property bool dealWithErrors: parent.dealWithErrors

  default property var _content: null

  // ---------------------------------------------------------------------------

  sourceComponent: orientation === Qt.Horizontal ? hGroup : vGroup
  width: parent.maxItemWidth

  // ---------------------------------------------------------------------------

  Component {
    id: hGroup

    FormHGroup {
      _content: loader._content
      label: loader.label
    }
  }

  Component {
    id: vGroup

    FormVGroup {
      _content: loader._content
      label: loader.label
    }
  }
}
