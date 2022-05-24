import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import 'ComboBox.js' as Logic

// =============================================================================

Controls.ComboBox {
  id: comboBox

  // ---------------------------------------------------------------------------

  property var iconRole
  property bool haveBorder: true
  property bool haveMargin: true
  property color backgroundColor: ComboBoxStyle.background.color.normal
  
  property int fitWidth: contentItem.fitWidth + ComboBoxStyle.indicator.dropDown.iconSize

  // ---------------------------------------------------------------------------

  background: Rectangle {
    border {
      color: ComboBoxStyle.background.border.color
      width: comboBox.haveBorder ? ComboBoxStyle.background.border.width : 0
    }

    color: comboBox.enabled
      ? comboBox.backgroundColor
      : ComboBoxStyle.background.color.readOnly

    radius: ComboBoxStyle.background.radius

    implicitHeight: ComboBoxStyle.background.height
    implicitWidth: ComboBoxStyle.background.width
  }

  // ---------------------------------------------------------------------------

  contentItem: Item {
    property int fitWidth: contentText.implicitWidth + ComboBoxStyle.contentItem.iconSize + contentLayout.anchors.leftMargin
    height: comboBox.height
    width: comboBox.width

    RowLayout {
      id: contentLayout
      anchors {
        fill: parent
        leftMargin: comboBox.haveMargin ? ComboBoxStyle.contentItem.leftMargin : 0
      }

      spacing: ComboBoxStyle.contentItem.spacing

      Icon {
        icon: Logic.getSelectedEntryIcon()
        iconSize: ComboBoxStyle.contentItem.iconSize

        visible: icon.length > 0
      }

      Text {
        id: contentText
        Layout.fillWidth: true

        color: ComboBoxStyle.contentItem.text.color
        elide: Text.ElideRight

        font.pointSize: ComboBoxStyle.contentItem.text.pointSize
        rightPadding: comboBox.indicator.width + comboBox.spacing

        text: Logic.getSelectedEntryText()
      }
    }
  }

  // ---------------------------------------------------------------------------

  indicator: Icon {
    icon: ComboBoxStyle.indicator.dropDown.icon
    iconSize: ComboBoxStyle.indicator.dropDown.iconSize
    overwriteColor: ComboBoxStyle.indicator.dropDown.color

    x: comboBox.width - width - comboBox.rightPadding
    y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
  }

  // ---------------------------------------------------------------------------

  delegate: CommonItemDelegate {
    id: item

    container: comboBox
    flattenedModel: comboBox.textRole.length &&
      (typeof modelData !== 'undefined' ? modelData : model)
    itemIcon: Logic.getItemIcon(item)
    width: comboBox.width
  }
}
