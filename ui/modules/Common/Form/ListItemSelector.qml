import Common 1.0

import 'ListItemSelector.js' as Logic

// =============================================================================

ScrollableListViewField {
  property alias currentIndex: view.currentIndex
  property alias iconRole: view.iconRole
  property alias model: view.model
  property alias textRole: view.textRole

  signal activated (int index)

  radius: 0

  ScrollableListView {
    id: view

    // -------------------------------------------------------------------------

    property string textRole
    property var iconRole

    // -------------------------------------------------------------------------

    anchors.fill: parent
    currentIndex: -1

    delegate: CommonItemDelegate {
      id: item

      container: view
      flattenedModel: view.textRole.length &&
        (typeof modelData !== 'undefined' ? modelData : model)
      itemIcon: Logic.getItemIcon(item)
      width: parent.width

      onClicked: activated(index)
    }
  }
}
